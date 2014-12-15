require 'addressable/uri'
require 'json'
require 'digest'
require 'cgi'

module SSWaffles

  class DiskBucket < Bucket
    def initialize(name, storage)
      super
      @basedir = storage.options.fetch(:basedir, storage.options.fetch('basedir', './s3/'))
      begin
        warmup(JSON.parse(File.open(key_file).read))
      rescue
        puts "DiskBucket: Could not load keyfile #{key_file}"
      end
    end

    def object_read obj
      raise 'No such key' unless obj.exists?
      File.open(bucket_object_filename obj.key).read
    end

    def object_write obj, data, options={}
      obj_file = bucket_object_filename obj.key
      assure_dir obj_file
      File.write(obj_file, data)
      objects.create(obj.key)
    end

    def object_delete obj
      obj_file = bucket_object_filename obj.key
      File.delete obj_file
      objects.delete obj.key
      keys_changed obj.key
    end

    def object_exists? obj
      File.exists? bucket_object_filename(obj.key)
    end

    def object_last_modified obj
      File.mtime bucket_object_filename(obj.key)
    end

    def clean_key key
      CGI.escape(Addressable::URI.escape(key))
    end

    def bucket_dir
      File.join @basedir, clean_key(name)
    end

    def key_file
      File.join bucket_dir, "_keys.json"
    end

    def bucket_object_filename key
      key = clean_key(key)
      hash = Digest::SHA1.hexdigest key
      File.join bucket_dir, hash[0..1], hash[2..3], key.slice(0,225)
    end

    def keys_changed(key, data=nil)
      # we should write the keys to disk
      File.write(key_file, JSON.generate(objects.keys))
    end

    def assure_dir key_file
      FileUtils.mkdir_p File.dirname(key_file)
    end

    private

  end
end
