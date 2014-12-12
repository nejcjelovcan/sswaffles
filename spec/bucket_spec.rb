require 'rspec/autorun'
require './lib/sswaffles.rb'

shared_examples_for SSWaffles::Bucket do
  let(:bucket) { storage.buckets['bucket']}

  it 'has a name' do
    bucket.name.should eq('bucket')
  end

  it 'has objects' do
    bucket.objects.should be_a(SSWaffles::ObjectCollection)
  end

  it 'object has a key' do
    object = bucket.objects['object1']
    object.key.should be_a(String)
  end

  it 'object has acl' do
    object = bucket.objects['object1']
    object.acl.should be_a(Hash)
  end

  it 'object has String public_url' do
    object = bucket.objects['object1']
    object.public_url.should be_a(String)
  end

  it 'object has Time last_modified' do
    object = bucket.objects['object1']
    object.write 'test'
    object.last_modified.should be_a(Time)
  end

end

shared_examples_for :WritableBucket do
  let(:bucket) { storage.buckets['bucket']}

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

describe SSWaffles::DiskBucket do
  let(:storage) { SSWaffles::Storage.new :Disk, basedir: './test_working/' }

  after(:all) do
    FileUtils.rm_rf('./test_working/')
  end

  it_behaves_like SSWaffles::Bucket
  it_behaves_like :WritableBucket
end

describe SSWaffles::MemoryBucket do
  let(:storage) { SSWaffles::Storage.new }

  it_behaves_like SSWaffles::Bucket
  it_behaves_like :WritableBucket
end

describe SSWaffles::AmazonreadonlyBucket do
  let(:storage) { SSWaffles::Storage.new :Amazonreadonly, s3: SSWaffles::Storage.new(:Memory)}

  it_behaves_like SSWaffles::Bucket
end