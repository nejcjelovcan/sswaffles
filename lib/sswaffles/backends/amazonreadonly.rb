module SSWaffles

  class AmazonreadonlyBucket < Bucket
    attr_reader :s3bucket

    def initialize(name, storage)
      super
      @s3bucket = storage.s3.buckets[name]
      warmup(@s3bucket.objects.map &:key)
    end

    def object_read obj
      raise 'No such key' unless obj.exists?
      s3bucket.objects[obj.key].read
    end

    def object_write obj, data, options={}
      puts "Will not write #{obj.key}"
    end

    def object_delete obj
      puts "WILL NOT DELETE #{obj.key}"
    end

    def object_exists? obj
      s3bucket.objects[obj.key].exists?
    end

    def object_last_modified obj
      s3bucket.objects[obj.key].last_modified
    end

  end

end