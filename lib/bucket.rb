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
  end

end