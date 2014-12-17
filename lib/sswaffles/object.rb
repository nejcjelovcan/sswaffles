
module SSWaffles

  class S3Object
    attr_reader :key, :bucket

    def initialize(key, bucket)
      @bucket = bucket
      @key = key
    end

    def read; bucket.object_read self; end
    def write(val, options={}); bucket.object_write self, val, options; end
    def exists?; bucket.object_exists? self; end
    def delete; bucket.object_delete self; end
    def last_modified; bucket.object_last_modified self; end
    def acl; bucket.object_acl self; end
    def acl=(val); bucket.object_acl_set self, val; end
    def public_url; bucket.object_public_url self; end
    def etag; bucket.object_metadata self, 'etag'; end
    def metadata; bucket.object_metadata self; end

    def to_s; "#{bucket.class}:#{bucket.name}/#{key}"; end
  end

end
