require 'rspec/autorun'
require './lib/storage.rb'

describe 'ObjectCollection' do
  let(:objects) { SSWaffles::Storage.new(:Memory).buckets['name'].objects }

  it 'has an object' do
    objects['test'].should be_a(SSWaffles::MemoryBucket::BucketObject)
  end

  it 'creates an object' do
    objects.create('test', '1')
    objects['test'].read.should eq('1')
  end

  it 'acts as array of keys (objects that exist!)' do
    objects['a'].write 1
    objects['b'].write 2
    objects['c'].write 3

    objects.map(&:key).should eq(%w[a b c])
    objects.count { |obj| obj.key != 'a' }.should eq(2)
    objects.select { |obj| obj.key != 'a' }.map(&:key).should eq(%w[b c])
    objects.to_a.map(&:key).should eq(%w[a b c])
  end

  it '#with_prefix' do
    objects['test1'].write 1
    objects['test2'].write 2
    objects['somethingelse'].write 3

    objects.with_prefix('test').map(&:key).should eq(%w[test1 test2])
  end
end