require File.expand_path(File.dirname(__FILE__)) + '/lib/boot.rb'

Gem::Specification.new do |s|
  s.name        = 'boot'
  s.version     = Boot::VERSION
  s.executables << 'boot'
  s.licenses    = ['GPL']
  s.summary     = "Create projects based on templates"
  s.description = "Allows you to quickly create new projecets based on templates."
  s.authors     = ["Sigurd Berg Svela"]
  s.email       = 'sigurdbergsvela@gmail.com'
  s.files       = `git ls-files -- lib/*`.split("\n")
  s.homepage    = 'https://github.com/sigurdsvela/boot'
  s.required_ruby_version = '>= 2.0.0'
end