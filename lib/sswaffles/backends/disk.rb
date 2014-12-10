require 'addressable/uri'
require 'json'

module SSWaffles

  class DiskBucket < Bucket
    def initialize(name, storage)
      super
      raise "Basedir option needed for DiskBucket" if basedir.nil?
      begin
        warmup(JSON.parse(File.open(key_file).read))
      rescue
        puts "DiskBucket: Could not load keyfile"
      end
    end

    def basedir
      storage.options.fetch(:basedir, storage.options.fetch('basedir', nil))
    end

    def clean_key key
      CGI.escape(Addressable::URI.escape(key))
    end

    def bucket_dir
      File.join basedir, clean_key(name)
    end

    def key_file
      File.join bucket_dir, "_keys.json"
    end

    def object_filename key
      key = clean_key(key)
      hash = Digest::SHA1.hexdigest key
      File.join hash[0..1], hash[2..3], key.slice(0,225)
    end

    def bucket_object_filename key
      File.join bucket_dir, object_filename(key)
    end

    def assure_dir key_file
      FileUtils.mkdir_p File.dirname(key_file)
    end

    def keys_changed(key, data=nil)
      # we should write the keys to disk
      File.write(key_file, JSON.generate(objects.keys))
    end

    class BucketObject < S3Object
      def key_file
        bucket.bucket_object_filename(key)
      end

      def read
        raise 'No such key' unless exists?
        File.open(key_file).read
      end

      def write(data, options={})
        bucket.assure_dir key_file
        File.write(key_file, data)
        bucket.objects.create(key)
      end

      def delete
        File.delete key_file
         # @TODO make BucketObjects adhere to S3::ObjectCollection - .delete(*objects)
        bucket.objects.delete key
        bucket.keys_changed key
      end

      def exists?
        File.exists? key_file
      end
    end
  end

end