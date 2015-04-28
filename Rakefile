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
  print "Installing..."
  `sudo gem install boot-* --no-document`
  print "done\n"
end

task :default => :test
