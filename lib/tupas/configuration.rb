module Tupas
  class Configuration
    include Singleton

    @@defaults = {
      message_type: '701',
      version: '002',
      service_providers: [],
      return_address: '',
      cancel_address: '',
      reject_address: '',
      key_version: '4',
      key_algorith: ''
    }

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
    end

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = "omniauth"
      logger
    end

  end
end
