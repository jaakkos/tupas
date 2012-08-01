# -*- encoding : utf-8 -*-
module Tupas
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'tupas.boot' do |app|
        ActionView::Base.send :include, ViewHelpers
        app.middleware.use Tupas::Rack
      end
    end
  end
end
