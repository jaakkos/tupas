module Tupas
  class Rack
    def initialize(app, conditional_block = nil)
      @app, @conditional_block = app, conditional_block
    end

    def call(env)
      puts env
      action = detect_url(env['PATH_INFO'])
      if action == :success
        process_respons_message(env['QUERY_STRING'], env)
      else
        @app.call(env)
      end
    end

    protected

    def config
      Tupas.config
    end

    def detect_url(path_info)
      if path_info =~ /\A\/_tupas\/(.)+\/success\z/
        :success
      elsif path_info =~ /\A\/_tupas\/(.)+\/reject\z/
        :reject
      elsif path_info =~ /\A\/_tupas\/(.)+\/cancel\z/
        :cancel
      else
        false
      end
    end

    def process_respons_message(query_string, env)
      begin
        _message = Messages::Response.new(query_string)
        responses(env, config.success_path, _message.to_hash)
      rescue Exceptions::IncompleteResponseMessage => exception_message
        responses(env, config.error_path, {:error => 'information_not_found', :message_number => exception_message.message})
      rescue Exceptions::InvalidResponseMessage
        responses(env, config.error_path, {error: 'invalid_response_message'})
      rescue Exceptions::InvalidMacForResponseMessage
        responses(env, config.error_path, {error: 'invalid_mac_for_response_message'})
      rescue Exceptions::TypeNotFoundResponseMessage
        responses(env, config.error_path, {error: 'message_type_missing_response_message'})
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