task :default => [:spec]

desc 'run specs'
task :spec do
  sh 'rspec spec --tag ~integration'
end

desc 'run specs with integration'
task :spec_all do
  sh 'rspec spec'
end
