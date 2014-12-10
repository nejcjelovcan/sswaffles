module SSWaffles

  class MemoryBucket < Bucket
    attr_reader :pool

    def initialize(name, storage)
      super
      @pool = {}
    end

    class BucketObject < S3Object
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

end