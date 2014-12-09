Gem::Specification.new do |s|
  s.name          = 'sswaffles'
  s.version       = '0.0.1'
  s.date          = '2014-12-09'
  s.summary       = 'AWS S3 replacement'
  s.description   = 'Waffles'
  s.files         = ["lib/storage.rb", "lib/bucketcollection.rb", "lib/bucket.rb", "lib/objectcollection.rb",
                     "lib/object.rb", "lib/backends/memory.rb", "lib/backends/disk.rb", "lib/backends/amazonreadonly.rb"]
  s.authors       = ['Nejc Jelovčan']
  s.homepage      = ''
  s.license       = 'MIT'
  s.require_paths = ["lib"]
end
