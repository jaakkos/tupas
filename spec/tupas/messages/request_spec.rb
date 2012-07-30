require 'spec_helper'

describe Tupas::Messages::Request do

  let(:klass)         { Tupas::Messages::Request }
  let(:instanse)      { Tupas::Messages::Request.new('123461') }
  let(:provider_hash) { {'A01Y_ACTION_ID' => 'Foo', 'not_in_has' => '1235', 'A01Y_KEYVERS' => '0001', 'secret' => '1234565'} }

  describe "#params" do
    it "should genere parameters for tupas request" do
      instanse.params.must_equal [
        {"A01Y_VERS"=>"0001", "A01Y_RCVID"=>"Elisa testi", "A01Y_IDTYPE"=>"12",
         "name"=>"Elisa Mobiilivarmenne testi", "url"=>"https://mtupaspreprod.elisa.fi/tunnistus/signature.cmd",
         "secret"=>"12345", "A01Y_ACTION_ID"=>701, "A01Y_LANGCODE"=>"FI", "A01Y_KEYVERS"=>1, "A01Y_ALG"=>3,
         "A01Y_CANLINK"=>"https://example.com/cancel", "A01Y_REJLINK"=>"https://example.com/reject",
         "A01Y_RETLINK"=>"https://example.com/return", "A01Y_STAMP"=>"123461",
         "A01Y_MAC"=>"c356b65479388a50ddadec5db6d1e1db66ba768322b523f1e127d246deca1046"},
        {"A01Y_VERS"=>"0001", "A01Y_RCVID"=>"Avoinministerio", "A01Y_IDTYPE"=>"12", "name"=>"Elisa Mobiilivarmenne",
         "url"=>"https://tunnistuspalvelu.elisa.fi/tunnistus/signature.cmd", "secret"=>"12345",
         "A01Y_ACTION_ID"=>701, "A01Y_LANGCODE"=>"FI", "A01Y_KEYVERS"=>1, "A01Y_ALG"=>3,
         "A01Y_CANLINK"=>"https://example.com/cancel", "A01Y_REJLINK"=>"https://example.com/reject",
         "A01Y_RETLINK"=>"https://example.com/return", "A01Y_STAMP"=>"123461",
         "A01Y_MAC"=>"4bf1479df3d0fdec8387fafca277190e2d93308534e32d1e4c59641af8aa5b86"}]
    end
  end

  describe "#calculate_mac" do
    it "should create mac" do
      instanse.send(:calculate_mac, provider_hash).must_equal 'fc104cad2746f5557af9a92fb8bd54ebd6bf6f25adc197c96ae0470333dc8da7'
    end
  end

  describe "#collect_variable_from" do
    it "should only use variables with key that starts with A01Y_" do
      instanse.send(:collect_variable_from, provider_hash).must_equal({"A01Y_ACTION_ID"=>"Foo", "A01Y_VERS"=>nil,
        "A01Y_RCVID"=>nil, "A01Y_LANGCODE"=>nil, "A01Y_STAMP"=>nil, "A01Y_IDTYPE"=>nil, "A01Y_RETLINK"=>nil,
        "A01Y_CANLINK"=>nil, "A01Y_REJLINK"=>nil, "A01Y_KEYVERS"=>"0001", "A01Y_ALG"=>nil, "A01Y_MAC"=>nil})
    end
  end

  describe "#combine_variables_to_string" do
    it "should combine hash variable to string with the secret" do
      instanse.send(:combine_variables_to_string, {'foo' => 'bar', 'bar' => 'foo'}, 'secret').must_equal 'bar&foo&secret&'
    end
  end
end