require 'rspec/autorun'
require './lib/sswaffles.rb'

describe 'BucketCollection' do
  let(:buckets) { SSWaffles::Storage.new(:Memory).buckets }

  it 'has a bucket' do
    buckets['test'].should be_a(SSWaffles::MemoryBucket)
  end
end