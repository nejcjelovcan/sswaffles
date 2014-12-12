# Simple Storage Waffles

Will substitute Amazon S3 Simple Storage Service (AWS::S3) instance with a custom-backend equivalent (disk, memory, mongo or readonly restricted AWS::S3)

```
s3 = SSWaffles::Storage.new :Disk, basedir: './s3/'
s3.buckets['bucketname'].objects['test.png'].read
```

## SSWaffles::Storage(bucket_type, options = {})
bucket_type|-
------------
nil               |default S3 API is used (needs s3 instance as :s3 options)
:Memory           |buckets are in-memory hashes of key=>value
:Disk             |buckets are folders on disk with keys in subfolders (basedir: ./s3/)
:Mongo            |buckets are collections in a mongo db, (host: localhost, port: 27017, db: 'sswaffles')
:Amazonreadonly   |buckets on S3 are used for reading, writing is ignored (needs s3 instance as :s3 option)

