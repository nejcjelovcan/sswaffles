require 'sswaffles/bucketcollection.rb'
require 'sswaffles/bucket.rb'
require 'sswaffles/objectcollection.rb'
require 'sswaffles/object.rb'
require 'sswaffles/backends/memory.rb'
require 'sswaffles/backends/disk.rb'
require 'sswaffles/backends/amazonreadonly.rb'

module SSWaffles

  # Storage abstracts out different storage systems (S3, memory, disk)
  # bucket_type:
  #   nil               default S3 API is used (needs s3 instance as :s3 options)
  #   :Memory           buckets are in-memory hashes of key=>value
  #   :Disk             buckets are folders on disk with keys in subfolders (needs :basedir option)
  #   :AmazonReadonly   buckets on S3 are used for reading, writing is ignored (needs s3 instance as :s3 option)
  class Storage
    attr_reader :buckets, :bucket_type, :options, :s3

    def initialize bucket_type=MemoryBucket, options={}
      @bucket_type = if bucket_type.is_a?(Class) && bucket_type < Bucket
        bucket_type
      else
        Object.const_get("SSWaffles::#{bucket_type}Bucket")
      end
      @options = options
      @s3 = options[:s3]
      @buckets = bucket_type.nil? ? @s3.buckets : BucketCollection.new(self)
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

end