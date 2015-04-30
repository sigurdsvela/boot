if (File.exists?('boot'))
  puts "Error: can not download into './boot'. Allready exists"
  exit()
end
puts "===> Downloading boot..."
`git clone https://github.com/sigurdsvela/boot`
Dir.chdir("boot") do
  # Get the versions
  `git fetch --tags`
  
  # Get the version
  version = `git tag | sort -n | tail -1`
  
  # Remove newline form version
  version = version[0..-2]
  
  puts "===> Installing latest version(#{version})"

  # Checkout, send all output to /dev/null
  system 'git checkout tags/#{version} &> /dev/null'

  puts "===> Downloading templates..."
  `git submodule init`
  `git submodule update`

  Dir.chdir("lib/templates") do
    `git submodule init`
    `git submodule update`
  end
  puts "===> Building boot..."
  `rake gembuild`
  puts "===> Installing boot..."
  `rake geminstall`
  puts "===> Done!"
  puts "===> Success: run 'boot help' for list of commands"
end
