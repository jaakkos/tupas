require 'rack'
require 'digest'
require 'singleton'
require 'logger'
require 'yaml'


module Tupas
  autoload :VERSION, 'tupas/version'
  autoload :Configurable, 'tupas/configuration'
  autoload :Rack, 'tupas/rack'

  module Messages
    autoload :Request,  'tupas/messages/request'
    autoload :Response, 'tupas/messages/response'
  end

  module Exceptions
    autoload :InvalidResponseMessage, 'tupas/exceptions'
    autoload :InvalidResponseHashAlgorithm, 'tupas/exceptions'
    autoload :InvalidMacForResponseMessage, 'tupas/exceptions'
    autoload :InvalidResponseMessageType, 'tupas/exceptions'
    autoload :IncompleteResponseMessage, 'tupas/exceptions'
    autoload :TypeNotFoundResponseMessage, 'tupas/exceptions'
  end

  module Utils
    module_function
    # REVIEW: Wrapper for Digest, if we need to changed to different lib - jaakko
    def sha256_hex(string = '')
      calculate_hex_hash_with(:sha_256, string)
    end

    def calculate_hex_hash_with(algorithm, string = '')
      case algorithm
        when :md5
          Digest::MD5.hexdigest(string)
        when :sha_1
          Digest::SHA1.hexdigest(string)
        when :sha_256
          Digest::SHA256.hexdigest(string)
        else
          raise ArgumentError, "Unkown hash algorithm: #{algorithm}"
      end
    end

    def root_path
      root ||= if ::ENV.key?('RACK_ROOT')
        ::ENV['RACK_ROOT']
      elsif defined?(::Rails)
        ::Rails.root
      elsif defined?(::Sinatra::Application)
        ::Sinatra::Application.root
      end
    end

    def load_settings_yaml(file)
      YAML.load(File.open(File.join(root_path, file)))
    end

  end
end

