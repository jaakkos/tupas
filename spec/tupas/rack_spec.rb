# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Tupas::Rack do
  describe "Middleware" do
    before do
      @app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, [""]] }
    end

    def response_array(index, replace_with)
      a = ['B02K_VERS','B02K_TIMESTMP','B02K_IDNBR','B02K_STAMP','B02K_CUSTNAME','B02K_KEYVERS','03','B02K_CUSTID','08','B02K_CUSTTYPE','B02K_USERNAME']
      a[index] = replace_with
      a
    end

    def response_string(index, replace_with)
      (response_array(index, replace_with) << calculate_mac(response_array(index, replace_with))).join('&') + '&'
    end

    def calculate_mac(response_array)
      Tupas::Messages::Response.any_instance.stubs(:valid_mac?).returns(true)
      Tupas::Messages::Response.new(full_response_string, 'elisa-mobiilivarmenne-testi').send(:calculate_mac, response_array, '12345')
    end


    let(:full_response_string) { "B02K_VERS&B02K_TIMESTMP&B02K_IDNBR&B02K_STAMP&B02K_CUSTNAME&B02K_KEYVERS&03&B02K_CUSTID&08&B02K_CUSTTYPE&B02K_USERNAME&#{valid_mac}" }
    let(:full_response_array)  { full_response_string.split('&')}
    let(:valid_mac)            { 'e496575d9927bf66e371a61c71a3ee5e9d7abbdbc5c168e1f00a99c53062d1ce' }
    let(:tupas_provider_secret){'123456789' }

    describe "Redirect user depending to resonse" do
      it "Tupas provider responses with invalid message" do
        request = Rack::MockRequest.env_for("/_tupas/elisa-mobiilivarmenne-testi/132465/132465/success?foo&bar&sfg")
        response = Tupas::Rack.new(@app).call(request)
        status(response).must_equal 301
        headers(response).must_equal({"Location" => "http://example.org/tupas/error?error=invalid_response_message", "Content-Type" => "text/plain"})
      end

      it "Tupas provider responses with message with invalid mac" do
        request = Rack::MockRequest.env_for("/_tupas/elisa-mobiilivarmenne-testi/132465/132465/success?02K_VERS&B02K_TIMESTMP&B02K_IDNBR&B02K_STAMP&B02K_CUSTNAME&B02K_KEYVERS&03&B02K_CUSTID&08&B02K_CUSTTYPE&B02K_USERNAME&4")
        response = Tupas::Rack.new(@app).call(request)
        status(response).must_equal 301
        headers(response).must_equal("Location"=>"http://example.org/tupas/error?error=invalid_mac_for_response_message", "Content-Type"=>"text/plain")
      end

      it "Tupas provider responses with message with out user info" do
        request = Rack::MockRequest.env_for("/_tupas/elisa-mobiilivarmenne-testi/132465/132465/success?#{response_string(8, '00')}")
        response = Tupas::Rack.new(@app).call(request)
        status(response).must_equal 301
        headers(response).must_equal({"Location"=>"http://example.org/tupas/error?error=message_type_missing_response_message", "Content-Type"=>"text/plain"})
      end

      it "Tupas provider responses with valid message" do
        request = Rack::MockRequest.env_for("/_tupas/elisa-mobiilivarmenne-testi/132465/132465/success?#{response_string(8, '02')}")
        response = Tupas::Rack.new(@app).call(request)
        status(response).must_equal 301
        headers(response).must_equal({"Location"=>"http://example.org/tupas/success?id=B02K_STAMP&name=B02K_CUSTNAME&provider_id=B02K_IDNBR&social_security_number_ending=B02K_CUSTID&tupas_id=B02K_TIMESTMP", "Content-Type"=>"text/plain"})
      end

      it "Tupas provider responses with invalid user info" do
        request = Rack::MockRequest.env_for("/_tupas/elisa-mobiilivarmenne-testi/132465/132465/success?#{response_string(8, '11')}")
        response = Tupas::Rack.new(@app).call(request)
        status(response).must_equal 301
        headers(response).must_equal({"Location"=>"http://example.org/tupas/error?error=information_not_found&message_number=11", "Content-Type"=>"text/plain"})
      end
    end
  end

  private
  def status(response)
    response[0]
  end

  def headers(response)
    response[1]
  end
end
