Gem::Specification.new do |s|
  s.name          = 'sswaffles'
  s.version       = '0.1.7'
  s.date          = '2014-12-22'
  s.summary       = 'AWS S3 replacement'
  s.description   = 'Waffles'
  s.files         = Dir["./lib/**/*"].select { |file| file =~ /\.rb$/ }
  s.authors       = ['Nejc Jelovčan']
  s.homepage      = ''
  s.license       = 'MIT'
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'addressable', '~> 2'
  s.add_runtime_dependency 'mongo', '~> 1'
  s.add_runtime_dependency 'bson_ext', '~> 1'
  s.add_runtime_dependency 'naught', '~> 1'
  s.add_runtime_dependency 'aws-sdk', '~> 1'
end
