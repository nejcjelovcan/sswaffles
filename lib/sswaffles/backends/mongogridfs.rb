require 'mongo'

module SSWaffles

  class MongogridfsBucket < Bucket
    attr_reader :grid

    def initialize(name, storage)
      super
      storage.global[:client] ||= Mongo::MongoClient.new(storage.options.fetch(:host, nil),
                                                         storage.options.fetch(:port, nil))
      storage.global[:db] ||= storage.global[:client][storage.options.fetch(:db, "sswaffles_") + "#{name}"]
      @grid ||= Mongo::Grid.new(storage.global[:db])
      #@collection = storage.global[:db][name]
      keys_changed # warmup
    end

    def object_read obj
      get_file(obj).read
    end

    def object_write obj, data, options={}
      object_delete(obj) if object_exists?(obj)
      @grid.put(data, {_id: obj.key, metadata: {
        last_modified: Time.new,
        metadata: options.fetch(:metadata, {}),
        #content_type: options.fetch(:content_type),
        #content_encoding: options.fetch(:content_encoding),
      }})
    end

    def object_exists? obj
      @grid.exist?(id_hash obj) != nil
    end

    def object_delete obj
      @grid.delete obj.key
    end

    def object_last_modified obj
      get_file(obj).metadata.fetch('last_modified')
    end

    def object_metadata obj, key=nil
      meta = get_file(obj).metadata.fetch('metadata')
      key.nil? ? meta : meta[key]
    end

    def keys_changed(key=nil, data=nil)
      collection.find({}, fields: {_id: true})
        .map { |doc| doc['_id'] }
        .each { |k| objects.create(k, nil, warmup: true) }
    end

    private

    def id_hash obj
      {_id: obj.key}
    end

    def get_file obj
      @grid.get(obj.key)
    rescue Mongo::GridFileNotFound => e
      raise 'No such key'
    end

    def collection
      grid.instance_variable_get :@files
    end
  end
end
