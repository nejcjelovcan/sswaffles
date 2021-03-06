require 'forwardable'

module SSWaffles

  # @TODO .delete is inherited from Hash but should adhere to S3::ObjectCollection - .delete(*objects)
  class ObjectCollection < Hash
    attr_reader :bucket
    alias_method :old_get, :[]

    extend Forwardable
    # this means that these array methods will be called on ==>>> self.values <<<==
    def_delegators :values, :to_a, :each, :count, :map, :reduce, :select, :inject, :reject, :collect

    def initialize bucket, keys=nil
      @bucket = bucket
    end

    def [](key)
      unless include?(key)
        S3Object.new key, @bucket
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

end