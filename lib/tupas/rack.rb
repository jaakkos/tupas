# -*- encoding : utf-8 -*-
module Tupas
  class Rack
    def initialize(app, conditional_block = nil)
      @app, @conditional_block = app, conditional_block
    end

    def call(env)
      if action = detect_url(env['PATH_INFO'])
        process_respons_message(env['QUERY_STRING'], action[:provider], env)
      else
        @app.call(env)
      end
    end

    protected

    def config
      Tupas.config
    end

    def detect_url(path_info)
      /\A\/_tupas\/(?<provider>(\w|-)+)\/(?<id>(\w|-)+)\/(?<type>success|reject|cancel)\z/.match(path_info)
    end

    def process_respons_message(query_string, provider, env)
      begin
        _message = Messages::Response.new(query_string, provider)
        responses(env, config.end_points["success_path"], _message.to_hash)
      rescue Exceptions::InvalidTupasProvider => exception_message
        responses(env, config.end_points["error_path"], {error: 'tupas_provider_not_found'})
      rescue Exceptions::IncompleteResponseMessage => exception_message
        responses(env, config.end_points["error_path"], {error: 'information_not_found', message_number: exception_message.message})
      rescue Exceptions::InvalidResponseMessage
        responses(env, config.end_points["error_path"], {error: 'invalid_response_message'})
      rescue Exceptions::InvalidMacForResponseMessage
        responses(env, config.end_points["error_path"], {error: 'invalid_mac_for_response_message'})
      rescue Exceptions::TypeNotFoundResponseMessage
        responses(env, config.end_points["error_path"], {error: 'message_type_missing_response_message'})
      end
    end

    def location_to_uri(location, env, params = {})
      if (location =~ ::URI::regexp).nil?
          _uri = Addressable::URI.parse("#{env['rack.url_scheme']}://#{env['SERVER_NAME']}").join(location)
      else
          _uri = Addressable::URI.parse(location)
      end
        _uri.query_values = params
        _uri
    end

    def responses(env, location, params = {})
      location = location_to_uri(location, env, params).to_s
      [301, {'Location' => location, 'Content-Type' => 'text/plain'}, []]
    end
  end
end
