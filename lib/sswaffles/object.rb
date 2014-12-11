
module SSWaffles

  class S3Object
    attr_reader :key, :bucket

    def initialize(key, bucket)
      @bucket = bucket
      @key = key
    end

    def read; raise 'Not Implemented'; end
    def write(val, options={}); raise 'Not Implemented'; end
    def exists?; raise 'Not Implemented'; end
    def delete; raise 'Not Implemented'; end
    def last_modified; Time.new; end

    def public_url; "fakestorage://#{key}"; end
    def acl; {}; end
    def to_s; "#{self.class}:#{bucket.name}/#{key}"; end
  end

end