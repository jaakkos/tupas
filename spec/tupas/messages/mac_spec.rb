require 'spec_helper'

describe "Tupas::Messages::Mac" do

  it "#join_values" do
    Tupas::Messages::Mac.join_values(['bar','foo','secret']).must_equal 'bar&foo&secret&'
  end

  describe "#calculate_hash" do
    let(:values) { ['ab','bd','as','bf'] }
    {md5: '01fcafea8912a8faceaa1388f1c5349b', sha_1: '3ae0df346dd4a7416d746d1948b906771597eda0', sha_256: '8feb7827d58c14cf5d93909c85aef88e5c6170b3808ff9ae9c1ab3e008f4a220'}.each_pair do |algorithm, hash|
      it "should use #{algorithm} for calculating hash" do
        Tupas::Messages::Mac.calculate_hash(algorithm, values).must_equal(hash)
      end
    end
  end
end