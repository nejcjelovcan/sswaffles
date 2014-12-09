require 'rspec/autorun'
require './lib/storage.rb'

describe 'MemoryBucket' do
  #let(:storage) { Storage.new DiskBucket, basedir: './working/' }
  let(:storage) { SSWaffles::Storage.new }
  let(:bucket) { storage.buckets['bucket'] }

  it 'has a name' do
    bucket.name.should eq('bucket')
  end

  it 'has objects' do
    bucket.objects.should be_a(SSWaffles::ObjectCollection)
  end

  it 'reads a written object' do
    object = bucket.objects['object1']
    object.write 'test'
    object.read.should eq('test')
  end

  it '.exists? returns true if exists' do
    object = bucket.objects['object2']
    object.exists?.should eq(false)
    object.write 'test'
    object.exists?.should eq(true)
  end

  it 'deletes an object' do
    object = bucket.objects['object1']
    object.write 'test'
    object.exists?.should eq(true)
    object.delete
    object.exists?.should eq(false)
  end
end