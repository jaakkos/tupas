require 'rack'
require 'digest'
require 'singleton'
require 'logger'
require 'yaml'
require 'multi_json'
require 'oj'


module Tupas
  autoload :VERSION, 'tupas/version'
  autoload :Configuration, 'tupas/configuration'
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

  def self.config
    Tupas::Configuration.instance
  end

  def self.configure
    yield config
  end

  def self.logger
    config.logger
  end

  def self.logger=(_logger)
    config.logger = _logger
  end

  module Utils
    module_function

    def sha256_hex(string = '')
      calculate_hex_hash_with(:sha_256, string)
    end

    # REVIEW: Wrapper for Digest, if we need to changed to different lib - jaakko
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

    def deep_merge(hash, other_hash = {})
      target = hash.dup
      other_hash.keys.each do |key|
        if other_hash[key].is_a? ::Hash and hash[key].is_a? ::Hash
          target[key] = deep_merge(target[key],other_hash[key])
          next
        end
        target[key] = other_hash[key]
      end
      target
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
  end
end

