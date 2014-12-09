module SSWaffles

  class BucketCollection
    def initialize storage
      @storage = storage
      @buckets = {}
    end

    def [](val)
      @buckets[val] ||= @storage.Bucket.new val, @storage
    end
  end

end