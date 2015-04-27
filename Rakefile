require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir['test/*Test.rb']
end

task :gembuild do
  print "Building..."
  `gem build boot.gemspec`
  print "done\n"
end

task :geminstall do
  `sudo gem install boot-* --no-document`
end

task :default => :test
