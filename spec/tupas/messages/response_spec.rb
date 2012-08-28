# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Tupas::Messages::Response do

  let(:default_valid_mac)    { '5AEB5D7B83AAE5383440A5BF2BFBE7741D4C800F' }
  let(:sample_valid_mac)     { 'D9624C29ECB853BE062A63CF2972A7E88177644C146D880F466DC5F728DE3281' }

  let(:query_string)                { "B02K_VERS=B02K_VERS&B02K_TIMESTMP=B02K_TIMESTMP&B02K_IDNBR=B02K_IDNBR&B02K_STAMP=B02K_STAMP&B02K_CUSTNAME=B02K_CUSTNAME&B02K_KEYVERS=B02K_KEYVERS&B02K_ALG=02&B02K_CUSTID=B02K_CUSTID&B02K_CUSTTYPE=02&B02K_USRID=B02K_USRID&B02K_USERNAME=B02K_USERNAME&B02K_MAC=#{default_valid_mac}"}
  let(:query_params_hash)           { Hash[query_string.split('&').map{|ad| ad.split('=')}]}
  let(:query_params_orderend_hash)  { ::ActiveSupport::OrderedHash.new(query_params_hash) }


  let(:full_response_string) { "B02K_VERS=0002&B02K_TIMESTMP=60020120822204827000001&B02K_IDNBR=0000004693&B02K_STAMP=2012082220481641964&B02K_CUSTNAME=DEMO+ANNA&B02K_KEYVERS=0001&B02K_ALG=03&B02K_CUSTID=010170-960F&B02K_CUSTTYPE=08&B02K_MAC=D9624C29ECB853BE062A63CF2972A7E88177644C146D880F466DC5F728DE3281" }
  let(:klass)                { Tupas::Messages::Response }
  let(:instanse)             { Tupas::Messages::Response.new(query_string, tupas_provider) }
  let(:tupas_provider)       {'elisa-mobiilivarmenne-testi' }

  let(:sample_response)      { instanse.send(:response_to_hash, full_response_string) }
  let(:response)             { instanse.send(:response_to_hash, query_string) }

  def response_string_with_type(type)
    "B02K_VERS=B02K_VERS&B02K_TIMESTMP=B02K_TIMESTMP&B02K_IDNBR=B02K_IDNBR&B02K_STAMP=B02K_STAMP&B02K_CUSTNAME=B02K_CUSTNAME&B02K_KEYVERS=B02K_KEYVERS&B02K_ALG=02&B02K_CUSTID=B02K_CUSTID&B02K_CUSTTYPE=#{type}&B02K_USRID=B02K_USRID&B02K_USERNAME=B02K_USERNAME&B02K_MAC=D9624C29ECB853BE062A63CF2972A7E88177644C146D880F466DC5F728DE3281"
  end

  describe "#is_hash?" do
    it "should detect if it's just string" do
      instanse.send(:is_hash?, query_string).must_equal(false)
    end

    it "should detect if it's Hash" do
      instanse.send(:is_hash?, query_params_hash).must_equal(true)
    end

    it "should detect if it's OrderedHash" do
      instanse.send(:is_hash?, query_params_orderend_hash).must_equal(true)
    end
  end

  describe "#response_string_to_hash" do
    it "should convert normal response string to hash" do
      instanse.send(:response_to_hash, full_response_string).must_equal(sample_response)
      instanse.send(:response_to_hash, query_string).must_equal(response)
    end
  end

  describe "#calculate_mac" do
    it "should calculate_mac" do
      instanse.send(:calculate_mac, response, tupas_provider).must_equal default_valid_mac
      instanse.send(:calculate_mac, sample_response, tupas_provider).must_equal sample_valid_mac
    end
  end

  describe "#mac_from_response" do
    it "should return mac from response hash" do
      instanse.send(:mac_from_response, sample_response).must_equal sample_valid_mac
    end
  end

  describe "#valid_mac?" do
    it "message is valid when hash equal to send from tupas provider" do
      instanse.send(:valid_mac?, response, '12345').must_equal true
    end
  end

  describe "#to_hash" do
    it "should return response from tupas provider as hash" do
      instanse.to_hash.must_equal({:company_name=>"B02K_CUSTNAME", :business_identity_code=>"B02K_CUSTID", :social_security_number=>"B02K_CUSTTYPE", :person_name=>"B02K_USERNAME", :tupas_id=>"B02K_TIMESTMP", :provider_id=>"B02K_IDNBR", :id=>"B02K_STAMP"})
    end
  end

  describe "#to_json" do
    it "should return response from tupas provider as json" do
      instanse.to_json.must_equal('{"company_name":"B02K_CUSTNAME","business_identity_code":"B02K_CUSTID","social_security_number":"B02K_CUSTTYPE","person_name":"B02K_USERNAME","tupas_id":"B02K_TIMESTMP","provider_id":"B02K_IDNBR","id":"B02K_STAMP"}')
    end
  end

  describe "#detect_response_type" do
    before(:each) do
      Tupas::Messages::Response.any_instance.stubs(:valid_mac?).returns(true)
    end

    it "should raise exception that type not found" do
      proc { instanse.send(:detect_response_type, response_string_with_type('00')) }.must_raise Tupas::Exceptions::TypeNotFoundResponseMessage
    end

    (1..8).each do |message_type|
      it "should return message type 01: #{Tupas::Messages::Response.new("B02K_VERS=B02K_VERS&B02K_TIMESTMP=B02K_TIMESTMP&B02K_IDNBR=B02K_IDNBR&B02K_STAMP=B02K_STAMP&B02K_CUSTNAME=B02K_CUSTNAME&B02K_KEYVERS=B02K_KEYVERS&B02K_ALG=02&B02K_CUSTID=B02K_CUSTID&B02K_CUSTTYPE=02&B02K_USRID=B02K_USRID&B02K_USERNAME=B02K_USERNAME&B02K_MAC=D9624C29ECB853BE062A63CF2972A7E88177644C146D880F466DC5F728DE3281", 'elisa-mobiilivarmenne-testi').send(:response_message_formats)[message_type-1]}" do
        puts "message : #{response_string_with_type("0#{message_type}")}"
        instanse.send(:detect_response_type, response_string_with_type("0#{message_type}")).must_equal instanse.send(:response_message_formats)[message_type-1]
      end
    end

    (10..12).each do |message_type|
      it "should raise Tupas::Exceptions::IncompleteResponseMessage" do
        proc{ instanse.send(:detect_response_type, response_string_with_type(message_type.to_s))}.must_raise Tupas::Exceptions::IncompleteResponseMessage
      end
    end

    it "should raise Tupas::Exceptions::InvalidResponseMessageType when message type is invalid" do
      proc{ instanse.send(:detect_response_type, '112')}.must_raise Tupas::Exceptions::InvalidResponseMessageType
    end
  end
end
