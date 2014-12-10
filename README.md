# Simple Storage Waffles

Amazon S3 Simple Storage Service, without the service, with extra waffles

Will substitute AWS::S3 instance with a custom-backend equivalent (disk or memory)

```
s3 = SSWaffles::Storage.new :Disk, basedir: './s3/'
s3.buckets['bucketname'].objects['test.png'].read
```
