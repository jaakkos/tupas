module Tupas
  module Rails
    class Railtie < ::Rails::Railtie
      initializer do
        Tupas.config.logger = Rails.logger
      end
    end
  end
end