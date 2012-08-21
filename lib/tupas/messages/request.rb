# -*- encoding : utf-8 -*-
module Tupas
  module Messages
    class Request
      attr_reader :request_stamp, :request_identifier

      def initialize(request_stamp, request_identifier = nil)
        @request_stamp, @request_identifier = request_stamp, request_identifier
      end

      def params
        _params = service_providers.collect do |provider|
          provider.merge!(default_settings)
          provider['a01y_stamp'] = request_stamp
          provider = convert_url_templates_to_urls(provider)
          provider['a01y_mac'] = calculate_mac(provider)
          provider
        end
      end

      private

      def default_settings
        Tupas.config.default
      end

      def service_providers
        Tupas.config.providers
      end

      def calculate_mac(parameters)
        params_for_mac = values_for_mac(parameters).values
        Mac.calculate_hash(select_hash_alogrith(parameters["a01y_alg"]), params_for_mac)
      end

      def select_hash_alogrith(algorithm)
        {'01' => :md5, '02' => :sha_1, '03' => :sha_256}[algorithm]
      end

      def values_for_mac(parameters)
        values_for_mac = correct_order.inject({}) do |hash, value|
          hash.merge(value => parameters[value])
        end
      end

      def correct_order
        ['a01y_action_id', 'a01y_vers', 'a01y_rcvid', 'a01y_langcode',
         'a01y_stamp', 'a01y_idtype', 'a01y_retlink', 'a01y_canlink',
         'a01y_rejlink', 'a01y_keyvers', 'a01y_alg', 'a01y_mac']
      end

      def convert_url_templates_to_urls(params)
        _params = params.collect do |value|
          if value[0] =~ /\Aa01y_(\w){3}link\z/i
            [value[0], Utils.url_from_template(value[1], {'provider' => params['id'], 'stamp' => params['a01y_stamp'], 'identifier' => request_identifier})]
          else
            value
          end
        end
        return Hash[_params]
      end

    end
  end
end
