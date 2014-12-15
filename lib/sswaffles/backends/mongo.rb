require 'mongo'

module SSWaffles

  class MongoBucket < Bucket
    attr_reader :collection

    def initialize(name, storage)
      super
      storage.global[:client] ||= Mongo::MongoClient.new(storage.options.fetch(:host, nil),
                                                         storage.options.fetch(:port, nil))
      storage.global[:db] ||= storage.global[:client][storage.options.fetch(:db, 'sswaffles')]
      @collection = storage.global[:db][name]
      keys_changed # warmup
    end

    def object_read obj
      find_one(obj)['value']
    end

    def object_write obj, data, options={}
      payload = {_id: obj.key, value: data, last_modified: Time.new}
      obj.exists? ? @collection.update(id_hash(obj), payload) : @collection.insert(payload)
    end

    def object_exists? obj
      !@collection.find_one(id_hash obj).nil?
    end

    def object_delete obj
      @collection.remove(id_hash(obj), limit: 1)
      objects.delete obj.key
    end

    def object_last_modified obj
      find_one(obj)['last_modified']
    end

    def keys_changed(key=nil, data=nil)
      @collection.find({}, fields: {_id: true})
        .map { |doc| doc['_id'] }
        .each { |k| objects.create(k, nil, warmup: true) }
    end

    private

    def id_hash obj
      {_id: obj.key}
    end

    def find_one obj
      @collection.find_one(id_hash obj).tap do |doc|
        raise 'No such key' if doc.nil?
      end
    end

  end
end
