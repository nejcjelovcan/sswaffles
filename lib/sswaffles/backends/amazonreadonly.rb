module SSWaffles

  class AmazonReadonlyBucket < Bucket
    attr_reader :s3bucket

    def initialize(name, storage)
      @s3bucket = storage.s3.buckets[name]
    end

    class BucketObject < S3Object
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

      def last_modified
        bucket.s3bucket.objects[key].last_modified
      end

    end
  end

end