require 'rspec/autorun'
require './lib/storage.rb'

describe 'Storage' do
  let(:storage) { SSWaffles::Storage.new :Memory }

  it 'has buckets' do
    storage.buckets.should be_a(SSWaffles::BucketCollection)
  end
end