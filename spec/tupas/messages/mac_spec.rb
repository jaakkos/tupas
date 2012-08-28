# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Tupas::Messages::Mac" do

  it "#join_values" do
    Tupas::Messages::Mac.join_values(['bar','foo','secret']).must_equal 'bar&foo&secret&'
  end

  describe "#calculate_hash" do
    let(:values) { ['ab','bd','as','bf'] }
    {md5: '01FCAFEA8912A8FACEAA1388F1C5349B', sha_1: '3AE0DF346DD4A7416D746D1948B906771597EDA0', sha_256: '8FEB7827D58C14CF5D93909C85AEF88E5C6170B3808FF9AE9C1AB3E008F4A220'}.each_pair do |algorithm, hash|
      it "should use #{algorithm} for calculating hash" do
        Tupas::Messages::Mac.calculate_hash(algorithm, values).must_equal(hash)
      end
    end
  end
end
