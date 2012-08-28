# -*- encoding : utf-8 -*-
module Tupas
  module Messages
    class Response
      def initialize(response, provider_identifier)
        @_response = normalize_response(response)
        #raise Exceptions::InvalidMacForResponseMessage unless valid_mac?(@_response)
        @data = response_to_data(@_response, provider_secret(provider_identifier))
        self
      end

      def raw_response
        @_response
      end

      def to_hash
        @data
      end

      def to_json
        MultiJson.dump(@data)
      end

      private

      def normalize_response(response)
        ( is_hash?(response) ? response : response_to_hash(response) ).with_indifferent_access
      end

      def is_hash?(response)
        # REVIEW: may be some issues with Ruby 1.8.x ( OrderedHash etc. )
        response.is_a?( Hash )
      end

      def response_to_hash(response_string)
        begin
        _response_hash = Hash[response_string.split('&').map{|query_param| query_param.split('=')}].keep_if{|key, value| valid_variable_keys.include?(key) && !value.nil? }
        rescue NoMethodError
          raise Exceptions::InvalidResponseString, "Response string is invalid format: #{response_string}"
        end
        raise Exceptions::InvalidResponseMessage, "Response message is too short, missing fields: #{response_string}" if _response_hash.length <= 8
        _response_hash
      end

      def provider_secret(provider_id)
        begin
          return Tupas.config.providers.find{|value| value['id'] == provider_id }['secret']
        rescue NoMethodError
          raise Exceptions::InvalidTupasProvider
        end
      end

      def default_settings
        Tupas.config.default
      end

      def service_providers
        Tupas.config.providers
      end

      def response_to_data(response, prodiver_secret)
        valid_mac?(response, prodiver_secret)
        detect_response_type(response).zip(response)
      end

      def valid_mac?(response, prodiver_secret)
        mac_from_response(response) == calculate_mac(response, prodiver_secret)
      end

      def mac_from_response(response)
        response['B02K_MAC']
      end

      def calculate_mac(response, tupas_provider_secret)
        Mac.calculate_hash(hash_algorithm(response), (orderend_variable_keys.map{|valid_key| response[valid_key]}.compact << tupas_provider_secret))
      end

      def hash_algorithm(response)
        begin
          case response['B02K_ALG']
            when '01' # = MD5
              :md5
            when '02' # = SHA-1
              :sha_1
            when '03' # = SHA-256
              :sha_256
            else
              raise Exceptions::InvalidResponseHashAlgorithm, "Unknow hash algorith for calculating MAC: #{response['B02K_ALG']}"
          end
        rescue NoMethodError
          raise Exceptions::InvalidResponseHashAlgorithm, "Hash algorith parameter (B02K_ALG) is missing from response: #{response}"
        end
      end

      def detect_response_type(response)
        puts "Response type #{response['B02K_CUSTTYPE']}"

        case response['B02K_CUSTTYPE']
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
          raise Exceptions::IncompleteResponseMessage, response['B02K_CUSTTYPE']
        else
          raise Exceptions::InvalidResponseMessageType, "Couldn't detect message type, type is set to #{response['B02K_CUSTTYPE']}."
        end
      end

      def response_message_formats
        [[:person, { 'B02K_CUSTNAME' => :name, 'B02K_USERID' => :social_security_number }],
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

      def valid_variable_keys
        ['B02K_VERS', 'B02K_TIMESTMP', 'B02K_IDNBR', 'B02K_STAMP', 'B02K_CUSTNAME', 'B02K_KEYVERS', 'B02K_ALG', 'B02K_CUSTID', 'B02K_CUSTTYPE', 'B02K_USERID', 'B02K_USERNAME', 'B02K_MAC']
      end


      def orderend_variable_keys
        ['B02K_VERS', 'B02K_TIMESTMP', 'B02K_IDNBR', 'B02K_STAMP', 'B02K_CUSTNAME', 'B02K_KEYVERS', 'B02K_ALG', 'B02K_CUSTID', 'B02K_CUSTTYPE', 'B02K_USERID', 'B02K_USERNAME'] #, 'B02K_MAC']
      end

    end
  end
end
