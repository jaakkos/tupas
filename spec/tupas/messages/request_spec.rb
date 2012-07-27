require 'spec_helper'

describe Tupas::Messages::Request do

  let(:klass)         { Tupas::Messages::Request }
  let(:instanse)      { Tupas::Messages::Request.new('123461') }
  let(:provider_hash) { {'A01Y_ACTION_ID' => 'Foo', 'not_in_has' => '1235', 'A01Y_KEYVERS' => '0001', 'secret' => '1234565'} }

  describe "#params" do
    it "should genere parameters for tupas request" do
      instanse.params.must_equal [{"A01Y_VERS"=>"0001", "A01Y_RCVID"=>"Elisa testi", "A01Y_IDTYPE"=>"12", "name"=>"Elisa Mobiilivarmenne testi", "url"=>"https://mtupaspreprod.elisa.fi/tunnistus/signature.cmd", "secret"=>"12345", "A01Y_ACTION_ID"=>701, "A01Y_LANGCODE"=>"FI", "A01Y_KEYVERS"=>1, "A01Y_ALG"=>3, "A01Y_CANLINK"=>"https://example.com/cancel", "A01Y_REJLINK"=>"https://example.com/reject", "A01Y_RETLINK"=>"https://example.com/return", "A01Y_STAMP"=>"123461", "A01Y_MAC"=>"1323b327d3175923e53aaee10a97622ffe078f1dfd651c99b850481b7aec169d"}, {"A01Y_VERS"=>"0001", "A01Y_RCVID"=>"Avoinministerio", "A01Y_IDTYPE"=>"12", "name"=>"Elisa Mobiilivarmenne", "url"=>"https://tunnistuspalvelu.elisa.fi/tunnistus/signature.cmd", "secret"=>"12345", "A01Y_ACTION_ID"=>701, "A01Y_LANGCODE"=>"FI", "A01Y_KEYVERS"=>1, "A01Y_ALG"=>3, "A01Y_CANLINK"=>"https://example.com/cancel", "A01Y_REJLINK"=>"https://example.com/reject", "A01Y_RETLINK"=>"https://example.com/return", "A01Y_STAMP"=>"123461", "A01Y_MAC"=>"c4342472885b547c740a046ac854ae45da2ca17801c22c42135b647ead647029"}]
    end
  end

  describe "#calculate_mac" do
    it "should create mac" do
      instanse.send(:calculate_mac, provider_hash).must_equal '938442193e4bdb6619e234a638ccb07c2307ac455c948b6a86ebe9b028fe7ba4'
    end
  end

  describe "#collect_variable_from" do
    it "should only use variables with key that starts with A01Y_" do
      instanse.send(:collect_variable_from, provider_hash).must_equal({'A01Y_ACTION_ID' => 'Foo', 'A01Y_KEYVERS' => '0001'})
    end
  end

  describe "#combine_variables_to_string" do
    it "should combine hash variable to string with the secret" do
      instanse.send(:combine_variables_to_string, {'foo' => 'bar', 'bar' => 'foo'}, 'secret').must_equal 'foo=bar&bar=foo&secret&'
    end
  end
end