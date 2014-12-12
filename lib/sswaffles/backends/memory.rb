module SSWaffles

  class MemoryBucket < Bucket
    attr_reader :pool

    def initialize(name, storage)
      super
      @pool = {}
    end

    def object_read obj
      raise 'No such key' unless obj.exists?
      pool[obj.key]
    end

    def object_write obj, data, options={}
      pool[obj.key] = data
      objects.create(obj.key)
    end

    def object_delete obj
      pool.delete obj.key
    end

    def object_exists? obj
      pool.include? obj.key
    end

    def object_last_modified obj
      Time.new
    end
  end

end