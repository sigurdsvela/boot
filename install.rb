puts "Downloading boot..."
`git clone https://github.com/sigurdsvela/boot`
Dir.chdir("boot") do
  puts "Downloading templates..."
  `git submodule init`
  `git submodule update`
  Dir.chdir("lib/templates") do
    `git submodule init`
    `git submodule update`
  end
  puts "Building boot..."
  `rake gembuild`
  puts "Installing boot..."
  `rake geminstall`
  puts "Done!"
  puts "Success: run 'boot help' for list of commands"
end
