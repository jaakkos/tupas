# -*- encoding : utf-8 -*-
ENV['LANG'] = 'en_US.UTF-8'
ENV['LC_CTYPE'] = 'en_US.UTF-8'
Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/matchers'
require 'rack/mock'
require 'mocha'
require 'fakeweb'
require 'differ'
require 'pp'
require 'timecop'

ENV['RACK_ROOT'] = File.expand_path('./spec/support')
ENV['RACK_ENV'] = 'test'

require 'tupas'

