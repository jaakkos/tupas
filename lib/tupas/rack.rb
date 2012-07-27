module Tupas
  class Rack
    def initialize(app, conditional_block = nil)
      @app, @path, @conditional_block = app, "/alive", conditional_block
    end

    def call(env)
      # Add here
    end

    def self.config
      Configuration.instance
    end

    def self.configure
      yield config
    end

    def self.logger
      config.logger
    end

  end
end