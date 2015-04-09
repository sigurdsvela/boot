require 'JSON'
require 'Boot/Lib/Core/InvalidConfigException.rb'

module Boot::Lib::Core
  class Config
    # The include paths
    attr_reader :template_include_paths
  
    # Initilize with path to config file
    def initialize(path)
      @filePath = path
      @file = File.open(path, 'rb')
      content = @file.read
      @config = JSON.parse(content)
      @template_include_paths = @config['templates-dir']

      # If templates-dir is not defined
      if @template_include_paths.nil?
        msg = ''
        msg << "Invalid config file: templates-dir not defined\n"
        msg << "Please set this to the directory(s) where your\n"
        msg << "templates are located\n"
        fail Boot::Lib::Core::InvalidConfigException.new(msg)
      end

      # If template dir is defined, but invalid path
      if !@template_include_paths.is_a?(Array) && !File.directory?(@templatesDir)
        msg = ''
        msg << "Invalid config file: '#{@templatesDir}' is not a directory\n"
        msg << "Please set this to the directory(s) where your "
        msg << "templates are located\n"
        fail Boot::Lib::Core::InvalidConfigException.new(msg)
      end

      # If template dit is an array
      if @template_include_paths.is_a?(Array)
        notDirs = []

        # Add each path that is invalid to notDirs
        @template_include_paths.each do |path|
          notDirs.push(path) unless File.directory? path
        end

        # If any element in notDirs, invalid config
        if notDirs.length > 0
          msg = ''
          msg << "Invalid config file:\n"
          msg << 'the path(s): ' + notDirs.join(', ') + "\n"
          msg << "Are not directories\n"
          fail Boot::Lib::Core::InvalidConfigException.new(msg)
        end
      end
    end
  end
end
