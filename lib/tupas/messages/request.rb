module Tupas
  module Messages
    class Request
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
        @_service_providers = load_service_providers_config
        @_default_settings = load_default_settings
      end

      def params
        _params = service_providers.collect do |provider|
          provider.merge!(default_params)
          provider['A01Y_STAMP'] = identifier
          provider['A01Y_MAC'] = calculate_mac(provider)
          provider
        end
      end

      def buttons
        # REVIEW: Do we need view layer?
      end

      private

      def load_default_settings
        Tupas::Utils.load_settings_yaml('config/default_settings.yml')
      end

      def load_service_providers_config
        Tupas::Utils.load_settings_yaml('config/service_providers.yml')
      end

      def calculate_mac(parameters)
        params_for_mac = collect_variable_from(parameters)
        params_as_string_with_secret = combine_variables_to_string(params_for_mac, parameters['secret'])
        Tupas::Utils.sha256_hex(params_as_string_with_secret)
      end

      def collect_variable_from(parameters)
        correct_order.merge( parameters.select{|key, value| key =~ /\Aa01y_(.)+/i } )
      end

      def combine_variables_to_string(parameters, secret)
        parameters.collect{|key, value| "#{value}"}.join('&') << '&' << secret << '&'
      end

      def default_params
        @_default_settings
      end

      def service_providers
        @_service_providers
      end

      def correct_order
        {'A01Y_ACTION_ID' => nil, 'A01Y_VERS' => nil, 'A01Y_RCVID' => nil, 'A01Y_LANGCODE' => nil,
         'A01Y_STAMP' => nil, 'A01Y_IDTYPE' => nil, 'A01Y_RETLINK' => nil, 'A01Y_CANLINK' => nil,
         'A01Y_REJLINK' => nil, 'A01Y_KEYVERS' => nil, 'A01Y_ALG' => nil, 'A01Y_MAC' => nil}
      end

    end
  end
end