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
    autoload :Request, 'tupas/messages/request'
  end

  module Utils
    module_function
    # REVIEW: Wrapper for Digest, if we need to changed to different lib - jaakko
    def sha256_hex(string = '')
      Digest::SHA256.hexdigest(string)
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

