# -*- encoding : utf-8 -*-
require 'rack'
require 'digest'
require 'singleton'
require 'logger'
require 'yaml'
require 'multi_json'
require 'oj'
require 'addressable/uri'
require 'addressable/template'


module Tupas
  autoload :VERSION, 'tupas/version'
  autoload :Configuration, 'tupas/configuration'
  autoload :Rack, 'tupas/rack'
  autoload :ViewHelpers, 'tupas/view_helpers'

  module Messages
    autoload :Mac,      'tupas/messages/mac'
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
    autoload :InvalidTupasProvider, 'tupas/exceptions'
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

    def url_from_template(template = '', parameters = {})
      ::Addressable::Template.new(template).expand(parameters).to_s
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

require 'tupas/rails' if defined?(::Rails)

