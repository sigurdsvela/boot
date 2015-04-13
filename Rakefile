require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir['test/*Test.rb']
end

task :gembuild do
  `gem build boot.gemspec`
end

task :geminstall do
  `sudo gem install boot-*`
end

task :default => :test
