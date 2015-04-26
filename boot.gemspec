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

  gemRootDir = File.dirname(File.expand_path(__FILE__))
  
  # get an array of submodule dirs by executing 'pwd' inside each submodule
  `git submodule --quiet foreach pwd`.split("\n").each do |submodule_path|

    # for each submodule, change working directory to that submodule
    Dir.chdir(submodule_path) do
 
      # issue git ls-files in submodule's directory
      submodule_files = `git ls-files`.split("\n")
 
      # prepend the submodule path to create absolute file paths
      submodule_files_fullpaths = submodule_files.map do |filename|
        "#{submodule_path}/#{filename}"
      end
 
      # remove leading path parts to get paths relative to the gem's root dir
      # (this assumes, that the gemspec resides in the gem's root dir)
      submodule_files_paths = submodule_files_fullpaths.map do |filename|
        filename.gsub "#{gemRootDir}/", ""
      end

      # add relative paths to gem.files
      s.files += submodule_files_paths
    end

  end

  # Hardcode include gitignores submodule
  Dir.chdir(Boot.dir + "/templates/gitignores") do
    submodule_path = Boot.dir + "/templates/gitignores"

    # issue git ls-files in submodule's directory
    submodule_files = `git ls-files`.split("\n")

    # prepend the submodule path to create absolute file paths
    submodule_files_fullpaths = submodule_files.map do |filename|
      "#{submodule_path}/#{filename}"
    end

    # remove leading path parts to get paths relative to the gem's root dir
    # (this assumes, that the gemspec resides in the gem's root dir)
    submodule_files_paths = submodule_files_fullpaths.map do |filename|
      filename.gsub "#{gemRootDir}/", ""
    end

    # add relative paths to gem.files
    s.files += submodule_files_paths
  end

end