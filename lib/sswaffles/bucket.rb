module SSWaffles

  class Bucket
    attr_reader :name, :storage, :objects

    def initialize(name, storage, keys=nil)
      @name = name
      @storage = storage
      @objects = ObjectCollection.new self
      warmup(keys) unless keys.nil?
    end

    def warmup keys
      keys.each do |key|
        objects.create(key, nil, warmup: true)
      end
    end

    def object_read obj; raise 'Not implemented'; end
    def object_write obj, data, options={}; raise 'Not implemented'; end
    def object_delete obj; raise 'Not implemented'; end
    def object_exists? obj; raise 'Not implemented'; end
    def object_last_modified obj; raise 'Not implemented'; end
    def object_metadata obj, key=nil; raise 'Not implemented'; end

    def object_public_url obj; "sswaffles://#{name}/#{obj.key}"; end
    def object_acl obj; {}; end

  end

end