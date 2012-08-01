# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Tupas::Messages::Response do

  let(:full_response_string) { "B02K_VERS&B02K_TIMESTMP&B02K_IDNBR&B02K_STAMP&B02K_CUSTNAME&B02K_KEYVERS&03&B02K_CUSTID&08&B02K_CUSTTYPE&B02K_USERNAME&#{valid_mac}" }
  let(:full_response_array)  { full_response_string.split('&')}
  let(:klass)                { Tupas::Messages::Response }
  let(:instanse)             { Tupas::Messages::Response.new(full_response_string, tupas_provider) }
  let(:valid_mac)            { 'a4d585c8d3dd9fe9f404a110583600b0aa22b1f74811636253394dd9a862a770' }
  let(:tupas_provider)       {'elisa-mobiilivarmenne-testi' }

  def response_string_with_type(type)
    "B02K_VERS&B02K_TIMESTMP&B02K_IDNBR&B02K_STAMP&B02K_CUSTNAME&B02K_KEYVERS&03&B02K_CUSTID&#{type}&08&B02K_CUSTTYPE&B02K_USERNAME&89d4859ed0f8129cb52ce1317b25600827a232e4eea14f29ca2bd21ff1551efc".split("&")
  end

  describe "#response_string_to_hash" do
    it "should convert full plain response string to hash" do
      instanse.send(:response_array_to_hash, full_response_array).must_equal({:company_name=>"B02K_CUSTNAME", :business_identity_code=>"B02K_CUSTID", :social_security_number=>"B02K_CUSTTYPE", :person_name=>"B02K_USERNAME", :tupas_id=>"B02K_TIMESTMP", :provider_id=>"B02K_IDNBR", :id=>"B02K_STAMP"})
    end
  end

  describe "#calculate_mac" do
    it "should calculate_mac" do
      full_response_array.pop
      instanse.send(:calculate_mac, full_response_array, tupas_provider).must_equal valid_mac
    end
  end

  describe "#retrieve_mac_from_response" do
    it "should return last variable from given array" do
      instanse.send(:retrieve_mac_from_response, [1,2,4]).must_equal 4
    end
  end

  describe "#valid_mac?" do
    it "message is valid when hash equal to send from tupas provider" do
      instanse.send(:valid_mac?, full_response_array).must_equal true
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
      it "should return message type 01: #{Tupas::Messages::Response.new('B02K_VERS&B02K_TIMESTMP&B02K_IDNBR&B02K_STAMP&B02K_CUSTNAME&B02K_KEYVERS&03&B02K_CUSTID&08&B02K_CUSTTYPE&B02K_USERNAME&a4d585c8d3dd9fe9f404a110583600b0aa22b1f74811636253394dd9a862a770', 'elisa-mobiilivarmenne-testi').send(:response_message_formats)[message_type-1]}" do
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
