Gem::Specification.new do |s|
  s.name          = 'sswaffles'
  s.version       = '0.1.1'
  s.date          = '2014-12-09'
  s.summary       = 'AWS S3 replacement'
  s.description   = 'Waffles'
  s.files         = Dir["./lib/**/*"].select { |file| file =~ /\.rb$/ }
  s.authors       = ['Nejc Jelovčan']
  s.homepage      = ''
  s.license       = 'MIT'
  s.require_paths = ["lib"]
end
