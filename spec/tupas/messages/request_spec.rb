# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Tupas::Messages::Request do
  let(:klass)         { Tupas::Messages::Request }
  let(:instanse)      { Tupas::Messages::Request.new('123461', '987654321') }
  let(:provider_hash) { {'a01y_action_id' => 'Foo', 'not_in_has' => '1235', 'a01y_keyvers' => '0001', 'a01y_rcvid' => 'sdfsdf', 'secret' => '1234565', 'a01y_alg'=>'03', 'a01y_rejlink' => 'http://example.com/{provider}/{stamp}/{identifier}/r', 'a01y_retlink'=>'http://example.com/{provider}/{stamp}/{identifier}/r', 'a01y_canlink'=>'http://example.com/{provider}/{stamp}/{identifier}/c', 'a01y_rcvid' => 'sfsdf'} }

  describe "#params" do
    it "should genere parameters for tupas request" do
      instanse.params.must_equal([{"a01y_vers"=>"0001", "a01y_rcvid"=>"Elisa testi", "a01y_idtype"=>"12", "name"=>"Elisa Mobiilivarmenne testi", "url"=>"https://mtupaspreprod.elisa.fi/tunnistus/signature.cmd", "id"=>"elisa-mobiilivarmenne-testi", "secret"=>"12345", "a01y_action_id"=>"701", "a01y_langcode"=>"FI", "a01y_keyvers"=>"0001", "a01y_alg"=>"03", "a01y_canlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne-testi/123461/987654321/cancel", "a01y_rejlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne-testi/123461/987654321/reject", "a01y_retlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne-testi/123461/987654321/success", "a01y_stamp"=>"123461", "a01y_mac"=>"b0d54080751954129e34c8b0bf3d710785977e7c7f6d7599ae466305338d4c78"}, {"a01y_vers"=>"0001", "a01y_rcvid"=>"Avoinministerio", "a01y_idtype"=>"12", "name"=>"Elisa Mobiilivarmenne", "url"=>"https://tunnistuspalvelu.elisa.fi/tunnistus/signature.cmd", "id"=>"elisa-mobiilivarmenne", "secret"=>"12345", "a01y_action_id"=>"701", "a01y_langcode"=>"FI", "a01y_keyvers"=>"0001", "a01y_alg"=>"03", "a01y_canlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne/123461/987654321/cancel", "a01y_rejlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne/123461/987654321/reject", "a01y_retlink"=>"http://localhost:3000/_tupas/elisa-mobiilivarmenne/123461/987654321/success", "a01y_stamp"=>"123461", "a01y_mac"=>"c0a7d37c8940548252e4649aa1f1a92664cab57274a93cfbc1589a73f283c601"}])
    end
  end

  describe "#calculate_mac" do
    it "should create mac" do
      instanse.send(:calculate_mac, provider_hash).must_equal 'ecf78a93182a98b07c4fa861107405d449f984fa04b5c2a79a356825ecdf039d'
    end
  end

  describe "#collect_variable_from" do
    it "should only use variables with key that starts with a01y_" do
      instanse.send(:values_for_mac, provider_hash).must_equal(
        {"a01y_action_id"=>"Foo", "a01y_vers"=>nil, "a01y_rcvid"=>"sfsdf", "a01y_langcode"=>nil, "a01y_stamp"=>nil, "a01y_idtype"=>nil, "a01y_retlink"=>"http://example.com/{provider}/{stamp}/{identifier}/r", "a01y_canlink"=>"http://example.com/{provider}/{stamp}/{identifier}/c", "a01y_rejlink"=>"http://example.com/{provider}/{stamp}/{identifier}/r", "a01y_keyvers"=>"0001", "a01y_alg"=>"03", "a01y_mac"=>nil})
    end
  end

  it "#convert_templates_to_urls" do
    instanse.send(:convert_url_templates_to_urls, {"id" => '12345', "A01Y_RETLINK"=>"http://example.com/{provider}/{stamp}/{identifier}/r", "A01Y_CANLINK"=>"http://example.com/{provider}/{stamp}/{identifier}/c",
     "A01Y_REJLINK"=>"http://example.com/{provider}/{stamp}/{identifier}/r", 'a01y_stamp' => 'sdfsdfsd', "A01Y_KEYVERS"=>"0001", "a01y_rcvid"=>'laajh'}).must_equal({"id"=>"12345", "A01Y_RETLINK"=>"http://example.com/12345/sdfsdfsd/987654321/r", "A01Y_CANLINK"=>"http://example.com/12345/sdfsdfsd/987654321/c", "A01Y_REJLINK"=>"http://example.com/12345/sdfsdfsd/987654321/r", "a01y_stamp"=>"sdfsdfsd", "A01Y_KEYVERS"=>"0001", "a01y_rcvid"=>"laajh"})
    end
end
