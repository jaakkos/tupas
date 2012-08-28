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
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'


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
    autoload :InvalidResponseString, 'tupas/exceptions'
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

  def env
    env ||= if ::ENV.key?('RACK_ENV')
      ::ENV['RACK_ENV']
    elsif defined?(::Rails)
      ::Rails.root
    elsif defined?(::Sinatra::Application)
      ::Sinatra::Application.env
    end
  end
  module_function :env

  def root
    root ||= if ::ENV.key?('RACK_ROOT')
      ::ENV['RACK_ROOT']
    elsif defined?(::Rails)
      ::Rails.root
    elsif defined?(::Sinatra::Application)
      ::Sinatra::Application.root
    end
  end
  module_function :root

  module Utils
    module_function

    def url_from_template(template = '', parameters = {})
      ::Addressable::Template.new(template).expand(parameters).to_s
    end
  end
end

require 'tupas/rails' if defined?(::Rails)

