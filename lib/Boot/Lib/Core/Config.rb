require 'JSON'

include Boot::Lib::Core

module Boot::Lib::Core
  class Config
    #config array
    attr_reader :config

    # The include paths
    attr_reader :templates_path
    
    def initialize(config)
      @config = config
      @templates_path = @config['templates_path']

      # If templates-dir is not defined
      if @templates_path.nil?
        msg = ''
        msg << "Invalid config file: templates-dir not defined\n"
        msg << "Please set this to the directory(s) where your\n"
        msg << "templates are located\n"
        fail InvalidConfigException.new msg
      end

      # If template dir is defined, but invalid path
      if !@templates_path.is_a?(Array) && !File.directory?(@templates_path)
        msg = ''
        msg << "Invalid config file: '#{@templates_path}' is not a directory\n"
        msg << "Please set this to the directory(s) where your "
        msg << "templates are located\n"
        fail InvalidConfigException.new msg
      end

      # If template dit is an array
      if @templates_path.is_a?(Array)
        notDirs = []

        # Add each path that is invalid to notDirs
        @templates_path.each do |path|
          notDirs.push(path) unless File.directory? path
        end

        # If any element in notDirs, invalid config
        if notDirs.length > 0
          msg = ''
          msg << "Invalid config file:\n"
          msg << 'the path(s): ' + notDirs.join(', ') + "\n"
          msg << "Are not directories\n"
          fail InvalidConfigException.new msg
        end
      end
    end
  end
end
