require 'zlib'

require 'rspec/autorun'
require './lib/sswaffles.rb'

shared_examples_for :ReadableBucket do
  before(:all) do
    @bucket = @storage.buckets['bucket']
  end

  it 'has a name' do
    @bucket.name.should eq('bucket')
  end

  it 'has objects' do
    @bucket.objects.should be_a(SSWaffles::ObjectCollection)
  end

  it 'object has a key' do
    object = @bucket.objects['object1']
    object.key.should be_a(String)
  end

  it 'object has String public_url' do
    object = @bucket.objects['object1']
    object.public_url.should be_a(String)
  end

  it 'object has Time last_modified' do
    object = @bucket.objects['object1']
    object.write 'test'
    object.last_modified.should be_a(Time)
  end

end

shared_examples_for :WritableBucket do
  before(:all) do
    @bucket = @storage.buckets['bucket']
  end

  it 'reads a written object' do
    object = @bucket.objects['object1']
    object.write 'test'
    object.read.should eq('test')
  end

  it '.exists? returns true if exists' do
    object = @bucket.objects['object2']
    object.exists?.should eq(false)
    object.write 'test'
    object.exists?.should eq(true)
  end

  it 'deletes an object' do
    object = @bucket.objects['object1']
    object.write 'test'
    object.exists?.should eq(true)
    object.delete
    object.exists?.should eq(false)
  end

end

shared_examples_for :ImmutableBucket do
  before(:all) do
    @bucket = @storage.buckets['bucket']
  end

  it 'does not write an object' do
    object = @bucket.objects['object1']
    object.write 'test'
    object.exists?.should eq(false)
  end

  it 'does not delete an object' do
    # write directly on "s3"
    @storage.s3.buckets[@bucket.name].objects['object1'].write 'test'
    object = @bucket.objects['object1']
    object.delete
    object.exists?.should eq(true)
  end
end

shared_examples_for :MetadataBucket do

  before(:all) do
    @bucket = @storage.buckets['bucket']
  end

  it 'has metadata' do
    object = @bucket.objects['object1']
    object.write 'test', metadata: {test: '1'}
    object.metadata.should eq({'test' => '1'})
  end

  it 'writes etag metadata and reads it back again' do
    object = @bucket.objects['object1']
    object.write 'test', metadata: {etag: 'etagetag'}
    object.etag.should eq('etagetag')
  end

end

shared_examples_for :EncodingBucket do
  before(:all) do
    @bucket = @storage.buckets['bucket']
  end

  it 'writes gzip data and reads it back again' do
    data = 'testtest'
    sio = StringIO.new
    gz = Zlib::GzipWriter.new(sio)
    gz.write(data); gz.close

    object = @bucket.objects['object1']
    object.write sio.string, content_type: 'text/plain', content_encoding: 'gzip'

    Zlib::GzipReader.new(StringIO.new(object.read)).read.force_encoding('utf-8').should eq(data)
  end

end

shared_examples_for :PermissionBucket do
  before(:all) do
    @bucket = @storage.buckets['bucket']
    @object = @bucket.objects['object']
  end

  it 'has .acl which is an AccessControlList instance' do
    @object.acl.should be_a(SSWaffles::AccessControlList)
  end

  it 'can call .grant(:read).to(:user) on .acl' do
    @object.acl.grant(:read).to(:group_uri => 'http://acs.amazonaws.com/groups/global/AllUsers')
  end

  it 'can set .acl' do
    @object.acl = SSWaffles::AccessControlList.new
  end

end


shared_examples_for :ObjectCollection do
  before(:all) do
    @objects = @storage.buckets['bucket'].objects
  end

  it 'has an object' do
    @objects['test'].should be_a(SSWaffles::S3Object)
  end

  it 'creates an object' do
    @objects.create('test', '1')
    @objects['test'].read.should eq('1')
  end

  it 'acts as array of keys (objects that exist!)' do
    @objects['a'].write 1
    @objects['b'].write 2
    @objects['c'].write 3

    @objects.map(&:key).should eq(%w[a b c])
    @objects.count { |obj| obj.key != 'a' }.should eq(2)
    @objects.select { |obj| obj.key != 'a' }.map(&:key).should eq(%w[b c])
    @objects.to_a.map(&:key).should eq(%w[a b c])

    # check if keys are cleaned after delete
    @objects['a'].delete
    @objects.map(&:key).should eq(%w[b c])
  end

  it 'filters objects with_prefix' do
    @objects['test1'].write 1
    @objects['test2'].write 2
    @objects['somethingelse'].write 3

    @objects.with_prefix('test').map(&:key).should eq(%w[test1 test2])
  end
end

describe SSWaffles::DiskBucket do
  before(:all) do
    @storage = SSWaffles::Storage.new :Disk, basedir: './test_s3/'
  end

  after(:all) do
    FileUtils.rm_rf('./test_s3/')
  end

  it_behaves_like :ReadableBucket
  it_behaves_like :WritableBucket
  it_behaves_like :EncodingBucket
  it_behaves_like :PermissionBucket

end

describe SSWaffles::MemoryBucket do
  before(:all) do
    @storage = SSWaffles::Storage.new :Memory
  end

  it_behaves_like :ReadableBucket
  it_behaves_like :WritableBucket
  it_behaves_like :EncodingBucket
  it_behaves_like :PermissionBucket
end

describe SSWaffles::AmazonreadonlyBucket do
  before(:all) do
    @storage = SSWaffles::Storage.new :Amazonreadonly, s3: SSWaffles::Storage.new(:Memory)
  end

  it_behaves_like :ReadableBucket
  it_behaves_like :ImmutableBucket
end

describe SSWaffles::MongoBucket, :integration => true do
  before(:all) do
    @storage = SSWaffles::Storage.new :Mongo, db: 'sswaffles_test'
  end

  after(:all) do
    @storage.global[:client].drop_database('sswaffles_test')
  end

  it_behaves_like :ReadableBucket
  it_behaves_like :WritableBucket
  it_behaves_like :MetadataBucket
  it_behaves_like :EncodingBucket
  it_behaves_like :PermissionBucket
end

describe SSWaffles::MongogridfsBucket, :integration => true do
  before(:all) do
    @storage = SSWaffles::Storage.new :Mongogridfs, db: 'sswaffles_'
  end

  after(:all) do
    @storage.global[:client].drop_database('sswaffles_bucket')
  end

  it_behaves_like :ReadableBucket
  it_behaves_like :WritableBucket
  it_behaves_like :MetadataBucket
  it_behaves_like :EncodingBucket
  it_behaves_like :PermissionBucket
end