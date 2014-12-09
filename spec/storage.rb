require 'minitest/autorun'
require_relative '../storage.rb'


describe 'Storage' do
  let(:storage) { Storage.new :Memory }

  it 'has buckets' do
    storage.buckets.instance_of?(Buckets).must_equal true
  end
end

describe 'Buckets' do
  let(:buckets) { Storage.new(:Memory).buckets }

  it 'has a bucket' do
    buckets['test'].instance_of?(MemoryBucket).must_equal true
  end
end

describe 'MemoryBucket' do
  let(:bucket) { Storage.new(:Memory).buckets['name'] }

  it 'has a name' do
    bucket.name.must_equal 'name'
  end

  it 'has objects' do
    bucket.objects.instance_of?(BucketObjects).must_equal true
  end

end

describe 'BucketObjects' do
  let(:objects) { Storage.new(:Memory).buckets['name'].objects }

  it 'has an object' do
    objects['test'].instance_of?(MemoryBucket::BucketObject).must_equal true
  end

  it 'creates an object' do
    objects.create('test', '1')
    objects['test'].read.must_equal '1'
  end

  it 'acts as array of keys (objects that exist!)' do
    objects['a'].write 1
    objects['b'].write 2
    objects['c'].write 3

    objects.map(&:key).must_equal %w[a b c]
    objects.count { |obj| obj.key != 'a' }.must_equal 2
    objects.select { |obj| obj.key != 'a' }.map(&:key).must_equal %w[b c]
    objects.to_a.map(&:key).must_equal %w[a b c]
  end

  it '#with_prefix' do
    objects['test1'].write 1
    objects['test2'].write 2
    objects['somethingelse'].write 3

    objects.with_prefix('test').map(&:key).must_equal %w[test1 test2]
  end
end

describe 'BaseBucketObject' do
  let(:object) { BaseBucketObject.new 'key', nil }

  it 'has a key' do
    object.key.must_equal 'key'
  end

  it 'has acl' do
    object.acl.instance_of?(Hash).must_equal true
  end

  it '#public_url returns a string' do
    object.public_url.instance_of?(String).must_equal true
  end
end

describe 'MemoryBucket' do
  #let(:storage) { Storage.new DiskBucket, basedir: './working/' }
  let(:storage) { Storage.new }

  it 'writes an object' do
    storage.buckets['bucket'].objects['object'].write 'test'
  end

  it 'reads a written object' do
    object = storage.buckets['bucket'].objects['object1']
    object.write 'test'
    object.read.must_equal 'test'
  end

  it '.exists? returns true if exists' do
    object = storage.buckets['bucket'].objects['object2']
    object.exists?.must_equal false
    object.write 'test'
    object.exists?.must_equal true
  end

  it 'deletes an object' do
    object = storage.buckets['bucket'].objects['object1']
    object.write 'test'
    object.exists?.must_equal true
    object.delete
    object.exists?.must_equal false
  end
end