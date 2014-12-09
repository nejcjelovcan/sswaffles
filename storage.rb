require 'cgi'
require 'addressable/uri'
require 'fileutils'
require 'digest'
require 'forwardable'
require 'json'

# Storage abstracts out different storage systems (S3, memory, disk)
# by taking S3 API as a reference
# bucket_type:
#   nil               default S3 API is used
#   :Memory           buckets are in-memory hashes of key=>value
#   :Disk             buckets are folders on disk with keys in subfolders
#   :AmazonReadonly   buckets on S3 are used for reading, writing is ignored
class Storage
  attr_reader :buckets, :bucket_type, :options, :s3

  def initialize bucket_type=MemoryBucket, options={}
    @bucket_type = if bucket_type.is_a?(Class) && bucket_type < BaseBucket
      bucket_type
    else
      Object.const_get("#{bucket_type}Bucket")
    end
    @options = options
    @s3 = options[:s3]
    @buckets = bucket_type.nil? ? @s3.buckets : Buckets.new(self)
    puts "Storage #{@bucket_type}"
  end

  def Bucket
    @bucket_type
  end

  def BucketObject
    @bucket_type::BucketObject
  end

  def import_bucket other_storage, bucket_name, options = {}, &block
    target_bucket = buckets[bucket_name]
    source_objects = other_storage.buckets[bucket_name].objects
    source_objects = source_objects.select &block unless block.nil?
    source_objects.each do |obj|
      puts "Importing #{obj.key}"
      unless options.fetch(:new_only, false) and target_bucket.objects[obj.key].exists?
        target_bucket.objects[obj.key].write(obj.read)
      end
    end
  end
end

class Buckets
  def initialize storage
    @storage = storage
    @buckets = {}
  end

  def [](val)
    @buckets[val] ||= @storage.Bucket.new val, @storage
  end
end

class BaseBucket
  attr_reader :name, :storage, :objects

  def initialize(name, storage, keys=nil)
    @name = name
    @storage = storage
    @objects = BucketObjects.new self
    warmup(keys) unless keys.nil?
  end

  def warmup keys
    keys.each do |key|
      objects.create(key, nil, warmup: true)
    end
  end
end

class BucketObjects < Hash
  attr_reader :bucket
  alias_method :old_get, :[]

  extend Forwardable
  # this means that these array methods will be called on ==>>> self.values <<<==
  def_delegators :values, :to_a, :each, :count, :map, :reduce, :select, :inject, :reject, :collect

  def initialize bucket, keys=nil
    @bucket = bucket
  end

  def [](key) # @TODO cache objects?
    unless include?(key)
      @bucket.storage.BucketObject.new key, @bucket
    else
      old_get key
    end
  end

  def with_prefix prefix
    values.select do |obj|
      obj.key.start_with? prefix
    end
  end

  def create key, data=nil, options = {}
    self[key] = self[key] # lol
    self[key].write data unless data.nil?
    bucket.keys_changed(key, data) if bucket.respond_to?(:keys_changed) && options[:warmup].nil?
  end
end

class BaseBucketObject
  attr_reader :key, :bucket

  def initialize(key, bucket)
    @bucket = bucket
    @key = key
  end

  def read; raise 'Not Implemented'; end
  def write(val, options={}); raise 'Not Implemented'; end
  def exists?; raise 'Not Implemented'; end
  def delete; raise 'Not Implemented'; end

  def acl; {}; end
  def public_url; "fakestorage://#{key}"; end
  def to_s; "#{self.class}:#{bucket.name}/#{key}"; end
end

class MemoryBucket < BaseBucket
  attr_reader :pool

  def initialize(name, storage)
    super
    @pool = {}
  end

  class BucketObject < BaseBucketObject
    def read
      raise 'No such key' unless exists?
      bucket.pool[key]
    end

    def write(data, options={})
      bucket.pool[key] = data
      bucket.objects.create(key)
    end

    def delete
      bucket.pool.delete key
    end

    def exists?
      bucket.pool.include? key
    end
  end
end

class DiskBucket < BaseBucket
  def initialize(name, storage)
    super
    raise "Basedir option needed for DiskBucket" unless storage.options[:basedir]
    begin
      warmup(JSON.parse(File.open(key_file).read))
    rescue
      puts "DiskBucket: Could not load keyfile"
    end
  end

  def clean_key key
    CGI.escape(Addressable::URI.escape(key))
  end

  def bucket_dir
    File.join storage.options[:basedir], clean_key(name)
  end

  def key_file
    File.join bucket_dir, "_keys.json"
  end

  def object_filename key
    key = clean_key(key)
    hash = Digest::SHA1.hexdigest key
    File.join hash[0..1], hash[2..3], key.slice(0,225)
  end

  def bucket_object_filename key
    File.join bucket_dir, object_filename(key)
  end

  def assure_dir key_file
    FileUtils.mkdir_p File.dirname(key_file)
  end

  def keys_changed(key, data=nil)
    # we should write the keys to disk
    File.write(key_file, JSON.generate(objects.keys))
  end

  class BucketObject < BaseBucketObject
    def key_file
      bucket.bucket_object_filename(key)
    end

    def read
      raise 'No such key' unless exists?
      File.open(key_file).read
    end

    def write(data, options={})
      bucket.assure_dir key_file
      File.write(key_file, data)
      bucket.objects.create(key)
    end

    def delete
      File.delete key_file
       # @TODO make BucketObjects adhere to S3::ObjectCollection - .delete(*objects)
      bucket.objects.delete key
      bucket.keys_changed key
    end

    def exists?
      File.exists? key_file
    end
  end
end

class AmazonReadonlyBucket < BaseBucket
  attr_reader :s3bucket

  def initialize(name, storage)
    @s3bucket = storage.s3.buckets[name]
  end

  class BucketObject < BaseBucketObject
    def read
      raise 'No such key' unless exists?
      bucket.s3bucket.objects[key].read
    end

    def write(data, options={})
      puts "Will not write #{key}"
    end

    def delete
      puts "WILL NOT DELETE #{key}"
    end

    def exists?
      bucket.s3bucket.objects[key].exists?
    end

  end
end
