# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Tupas::Messages::Request do
  let(:klass)         { Tupas::Messages::Request }
  let(:instanse)      { Tupas::Messages::Request.new('123461') }
  let(:provider_hash) { {'a01y_action_id' => 'Foo', 'not_in_has' => '1235', 'a01y_keyvers' => '0001', 'a01y_rcvid' => 'sdfsdf', 'secret' => '1234565', 'a01y_alg'=>'03', 'a01y_rejlink' => 'http://example.com/{provider}/{identifier}/r', 'a01y_retlink'=>'http://example.com/{provider}/{identifier}/r', 'a01y_canlink'=>'http://example.com/{provider}/{identifier}/c', 'a01y_rcvid' => 'sfsdf'} }

  describe "#params" do
    it "should genere parameters for tupas request" do
      instanse.params.must_equal [
        {"a01y_vers"=>"0001", "a01y_rcvid"=>"Elisa testi", "a01y_idtype"=>"12", "name"=>"Elisa Mobiilivarmenne testi", "url"=>"https://mtupaspreprod.elisa.fi/tunnistus/signature.cmd", "id"=>"elisa-mobiilivarmenne-testi", "secret"=>"12345", "a01y_action_id"=>"701", "a01y_langcode"=>"FI", "a01y_keyvers"=>"0001", "a01y_alg"=>"03", "a01y_canlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne-testi/123461/cancel", "a01y_rejlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne-testi/123461/reject", "a01y_retlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne-testi/123461/success", "a01y_stamp"=>"123461", "a01y_mac"=>"5366736881353b08fa080085242ad2b6c3bddef00b92124b35ab2adf5e2a5517"}, {"a01y_vers"=>"0001", "a01y_rcvid"=>"Avoinministerio", "a01y_idtype"=>"12", "name"=>"Elisa Mobiilivarmenne", "url"=>"https://tunnistuspalvelu.elisa.fi/tunnistus/signature.cmd", "id"=>"elisa-mobiilivarmenne", "secret"=>"12345", "a01y_action_id"=>"701", "a01y_langcode"=>"FI", "a01y_keyvers"=>"0001", "a01y_alg"=>"03", "a01y_canlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne/123461/cancel", "a01y_rejlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne/123461/reject", "a01y_retlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne/123461/success", "a01y_stamp"=>"123461", "a01y_mac"=>"fa0de3c36420d54a0fbe74225ef4429135f5caae128d9e29daafc16676d4476e"}]
    end
  end

  describe "#calculate_mac" do
    it "should create mac" do
      instanse.send(:calculate_mac, provider_hash).must_equal '37cb1dced9ddb6266459a285794f1c14761b429f2fae96a74c71380fc73ac687'
    end
  end

  describe "#collect_variable_from" do
    it "should only use variables with key that starts with a01y_" do
      instanse.send(:values_for_mac, provider_hash).must_equal(
        {"a01y_action_id"=>"Foo", "a01y_vers"=>nil, "a01y_rcvid"=>"sfsdf", "a01y_langcode"=>nil, "a01y_stamp"=>nil,
         "a01y_idtype"=>nil, "a01y_retlink"=>"http://example.com/{provider}/{identifier}/r",
         "a01y_canlink"=>"http://example.com/{provider}/{identifier}/c", "a01y_rejlink"=>"http://example.com/{provider}/{identifier}/r",
         "a01y_keyvers"=>"0001", "a01y_alg"=>"03", "a01y_mac"=>nil})
    end
  end

  it "#convert_templates_to_urls" do
    instanse.send(:convert_url_templates_to_urls, {"id" => '12345', "A01Y_RETLINK"=>"http://example.com/{provider}/{identifier}/r", "A01Y_CANLINK"=>"http://example.com/{provider}/{identifier}/c",
     "A01Y_REJLINK"=>"http://example.com/{provider}/{identifier}/r", 'a01y_stamp' => 'sdfsdfsd', "A01Y_KEYVERS"=>"0001", "a01y_rcvid"=>'laajh'}).must_equal ({"id"=>"12345", "A01Y_RETLINK"=>"http://example.com/12345/sdfsdfsd/r", "A01Y_CANLINK"=>"http://example.com/12345/sdfsdfsd/c", "A01Y_REJLINK"=>"http://example.com/12345/sdfsdfsd/r", "a01y_stamp"=>"sdfsdfsd", "A01Y_KEYVERS"=>"0001", "a01y_rcvid"=>"laajh"})
  end
end
