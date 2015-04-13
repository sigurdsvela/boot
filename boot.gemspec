Gem::Specification.new do |s|
  s.name        = 'boot'
  s.version     = '0.1.0'
  s.executables << 'boot'
  # Puts the config file in the same dir as the exec
  s.executables << 'boot-config.json'
  s.licenses    = ['GPL']
  s.summary     = "Create projects based on templates"
  s.description = "Allows you to quickly create new projecets based on templates."
  s.authors     = ["Sigurd Berg Svela"]
  s.email       = 'sigurdbergsvela@gmail.com'
  s.files       = `git ls-files -- lib/*`.split("\n") + `git ls-files -- bin/*`.split("\n")
  s.homepage    = 'https://github.com/sigurdsvela/boot'
  s.required_ruby_version = '>= 2.0.0'
end