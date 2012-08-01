# -*- encoding : utf-8 -*-
module Tupas
  module Messages
    class Response

      def initialize(response_as_string, provider_identifier = '')

        @_response_as_array = response_string_to_array(response_as_string)
        @_provider_secret = provider_secret(provider_identifier)
        raise Exceptions::InvalidMacForResponseMessage unless valid_mac?(@_response_as_array)
        @_response_as_hash = response_array_to_hash(@_response_as_array)
      end

      def to_hash
        @_response_as_hash
      end

      def to_json
        MultiJson.dump(@_response_as_hash)
      end

      private

      def provider_secret(provider_identifier)
        begin
          return Tupas.config.providers.find{|value| value['id'] == provider_identifier }['secret']
        rescue NoMethodError => exception
          raise Exceptions::InvalidTupasProvider
        end
      end

      def default_settings
        Tupas.config.default
      end

      def service_providers
        Tupas.config.providers
      end

      def response_string_to_array(response_as_string)
        _response_array = response_as_string.split('&')
        raise Exceptions::InvalidResponseMessage, "Response message is too short, missing fields: #{response_as_string}" if _response_array.length <= 8
        _response_array
      end

      def response_array_to_hash(response_as_array)
        _response = {}
        _fields_for_parsing = detect_response_type(response_as_array)
        _response[_fields_for_parsing.first] = {}
        _fields_for_parsing.last.merge(default_response_fields).each do |_field|
          _response[_fields_for_parsing.first][_field.last] = response_as_array.at(_field.first)
        end
        _response[_fields_for_parsing.first]
      end

      def valid_mac?(response_as_array)
        _mac_from_provider = retrieve_mac_from_response(response_as_array)
        _calculated_mac_from_response = calculate_mac(response_as_array, @_provider_secret)
        _mac_from_provider == _calculated_mac_from_response
      end

      def retrieve_mac_from_response(response_as_array)
        response_as_array.pop
      end

      def calculate_mac(response_as_array, tupas_provider_secret)
        _hash_algorithm = detect_hash_algorithm(response_as_array)
        _fields_for_calculating_mac_as_string = retrieve_field_for_calculating_mac((response_as_array << tupas_provider_secret))
        Mac.calculate_hash(_hash_algorithm, _fields_for_calculating_mac_as_string)
      end

      def detect_hash_algorithm(response_as_array)
        case response_as_array[6].to_s
          when '01' # = MD5
            :md5
          when '02' # = SHA-1
            :sha_1
          when '03' # = SHA-256
            :sha_256
          else
            raise Exceptions::InvalidResponseHashAlgorithm, "Unknow hash algorith for calculating MAC: #{response_as_array[6]}"
        end
      end

      def retrieve_field_for_calculating_mac(response_as_array)
        response_as_array[0..(response_as_array.length - 2)]
      end

      def detect_response_type(response_as_array)
        case response_as_array[8].to_s
        when '00' # = tunnus ei ole tiedossa
          # Arvoa "00" käytetään, jos mitään tunnistetta ei löydy.
          raise Exceptions::TypeNotFoundResponseMessage
        when '01' # = selväkielinen henkilötunnus
          # Arvoa "01” käytetään, mikäli on pyydetty selväkielistä tunnusta
          # ja palautetaan vain henkilötunnus.
          # Kentässä 5 on henkilön nimi ja
          # kentässä 8 on selväkielinen henkilötunnus.
          return response_message_formats[0]

        when '02' # = selväkielinen henkilötunnuksen tarkenne
          # Arvoa "02" käytetään, mikäli on pyydetty typistettyä tunnusta ja
          # palautetaan vain henkilötunnuksen tarkenne.
          # Kentässä 5 on henkilön nimi ja
          # kentässä 8 on selväkielisen henkilötunnuksen loppuosa.
          return response_message_formats[1]

        when '03' # = selväkielinen Y-tunnus
          # Arvoa "03" käytetään, mikäli on pyydetty selväkielistä tunnusta
          # ja palautetaan vain y-tunnus.
          # Kentässä 5 on yrityksen nimi ja
          # kentässä 8 on selväkielinen y-tunnus.
          return response_message_formats[2]

        when '04' # = selväkielinen sähköinen asiointitunnus
          # Arvoa "04" käytetään, mikäli on pyydetty selväkielistä tunnusta
          # ja palautetaan vain sähköinen asiointitunnus.
          # Kentässä 5 on yrityksen nimi ja
          # kentässä 8 on selväkielinen asiointitunnus.
          return response_message_formats[3]

        when '05' # = salattu henkilötunnus
          # Arvoa "05" käytetään, mikäli on pyydetty salattua tunnusta ja
          # palautetaan vain henkilötunnus.
          # Kentässä 5 on henkilön nimi ja
          # kentässä 8 on salattu henkilötunnus.
          return response_message_formats[4]

        when '06' # = salattu Y-tunnus
          # Arvoa "06" käytetään, mikäli on pyydetty salattua tunnusta ja
          # palautetaan vain y-tunnus.
          # Kentässä 5 on yrityksen nimi ja
          # kentässä 8 on salattu y-tunnus.
          return response_message_formats[5]

        when '07' # = salattu sähköinen asiointitunnus
          # Arvoa "07" käytetään, mikäli on pyydetty salattua tunnusta ja
          # palautetaan vain sähköinen asiointitunnus (ei käytössä Sammossa).
          # Kentässä 5 on asiakkaan nimi ja
          # kentässä 8 on salattu sähköinen asiointitunnus.
          return response_message_formats[6]

        when '08' # = selväkielinen Y-tunnus ja selväkielinen yrityskäyttäjän henkilötunnus, tai
                  # pankin ja palveluntuottajan keskenään sopima muu tunnus
          # Arvoa "08" käytetään mikäli on pyydetty selväkielisiä tunnuksia.
          # Kentässä 5 on yrityksen nimi,
          # kentässä 8 on selväkielinen y-tunnus,
          # kentässä 10 on selväkielinen yrityskäyttäjän henkilötunnus ja
          # kentässä 11 on yrityskäyttäjän nimi
          return response_message_formats[7]

        when '09' # = salattu Y-tunnus ja salattu yrityskäyttäjän henkilötunnus, tai pankin ja
                  # palveluntuottajan keskenään sopima salattu muu tunnus
          # Arvoa "09" käytetään mikäli on pyydetty salattuja tunnuksia.
          # kentässä 5 on yrityksen nimi,
          # kentässä 8 on salattu y-tunnus,
          # kentässä 10 on salattu yrityskäyttäjän henkilötunnus ja
          # kentässä 11 on yrityskäyttäjän nimi
          return response_message_formats[8]

        when '10', '11', '12' # = Kaikkia tai osaa pyydetyistä tiedoista ei ole löytynyt.
          # Kentän Yksilöintitiedon tyyppi (B02K_CUSTTYPE) tiedot palautetaan kyse-
          # lysanoman hylätty-osoite-kentässä olevaan osoitteeseen. Yksilöintitiedon tyy-
          # pin toinen numero (Y) ilmoittaa, mitä tietoja asiakkaasta ei löydy. Tällöin pal-
          # veluntarjoaja pystyy automatisoimaan virhevastauksensa asiakkaalle eri tilan-
          # teissa.
          #
          # 10 = Ei pyydettyjä tietoja asiakkaasta.
          # 11 = Yritysasiakkaan käyttäjästä ei henkilötunnusta.
          # 12 = Yritysasiakkaasta ei Y-tunnusta.
          raise Exceptions::IncompleteResponseMessage, response_as_array[8]
        else
          raise Exceptions::InvalidResponseMessageType, "Couldn't detect message type, type is set to #{response_as_array[8]}."
        end
      end

      def response_message_formats
        [[:person, { 4 => :name, 7 => :social_security_number }],
         [:person, { 4 => :name, 7 => :social_security_number_ending }],
         [:company, { 4 => :name, 7 => :business_identity_code }],
         [:company, { 4 => :name, 7 => :client_identifier }],
         [:person, { 4 => :name, 7 => :encrypted_social_security_number }],
         [:company, { 4 => :name, 7 => :encrypted_business_identity_code }],
         [:person, { 4 => :name, 7 => :encrypted_client_identifier }],
         [:combination, { 4 => :company_name, 7 => :business_identity_code,  9 => :social_security_number, 10 => :person_name }],
         [:combination, { 4 => :company_name, 7 => :encrypted_business_identity_code,  9 => :encrypted_social_security_number, 10 => :person_name }]
        ]
      end

      def default_response_fields
        {1 => :tupas_id, 2 => :provider_id, 3 => :id}
      end


      def variable_keys_for_response
        ['B02K_VERS', 'B02K_TIMESTMP', 'B02K_IDNBR', 'B02K_STAMP', 'B02K_CUSTNAME', 'B02K_KEYVERS', 'B02K_ALG', 'B02K_CUSTID', 'B02K_CUSTTYPE', 'B02K_USERID', 'B02K_USERNAME', 'B02K_MAC']
      end

    end
  end
end
