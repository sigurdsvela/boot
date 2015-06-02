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
  loading = Thread.new {
    i = 3
    while (true) do
      print "\r"
      print "              "
      print "\r"
      print "Installing"
      print '.' * ((i%4))
      i+=1
      sleep 0.2
    end
  }
  install = Thread.new {
    `sudo gem install boot-cli-*`
  }
  install.join
  loading.exit
  puts 'done'
end

task :default => :test
