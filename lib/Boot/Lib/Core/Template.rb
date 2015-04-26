require 'fileutils.rb'
require 'json-schema'

include Boot::Lib::Core

module Boot::Lib::Core
  class Template
    attr_reader :name
    attr_reader :description
    attr_reader :static_files
    attr_reader :path

    # Non static files, based on arguments
    # Arguments with values, fx. --vcs git, or --vcs=git
    #
    # Structure
    # "--vcs" : {     //Argument options, requires a value
    #   "values" : {
    #     "git" : [{"vcs/.gitignore":".gitignore"}],
    #     "svn" : [{"vcs/.svnignore":".svnignore"}]
    #   }
    #   "alias" : ["-v"] //Not implemented yet
    #   "description" : "Choose version controll system for the project",
    #   "required" : false,
    #   "default" : "git" //Can not be used with require:true
    # }
    #
    # "--on-or-off" : {
    #   "alias" : ["-o", "--on"] //Not implemented yet
    #   "files" : [{"files/to/add":"some/dir/file"}, {"if/present":"some/dir/file"}],
    #   "description" : "some description",
    # }
    attr_reader :option_files

    # Slop options object
    attr_reader :options

    # Creates a Template object
    # Might throw an InvalidTemplateException
    def initialize(path)
      # Check the template
      if (!File.directory?(path))
        fail InvalidTemplateException.new("Path is not a directory")
      end
      if (!File.exist?(path + "/template.json"))
        fail InvalidTemplateException.new("Missing template.json file")
      end

      templateJsonFile = File.open(path + "/template.json")
      templateConfig = JSON.parse(templateJsonFile.read)

      templateJsonSchemaFile = File.open(Boot::LIB_PATH + '/template.json-schema')
      templateJsonSchema = JSON.parse(templateJsonSchemaFile.read)

      errors = JSON::Validator.fully_validate(templateConfig, templateJsonSchema)
      if (errors.length > 0)
        msg = ''
        msg << 'Invalid template.json file for '
        msg << "#{name} template in #{path}\n"
        msg << errors * "\n"

        throw new InvalidTemplateException msg
      end


      @name = templateConfig['name'];
      @description = templateConfig['description']
      @static_files = templateConfig['static']
      @path = path
      @option_files = templateConfig['options']
      @option_files = {} if @option_files.nil?
      @options = Slop::Options.new

      options.banner = "usage: #{$0} new --template #{name} [--out DIR] [options]"

      # Create slop option object
      option_files.each do |option, value|
        if (!value['files'].nil?) # This is a flag
          options.on option, value['description']
        elsif (!value['values'].nil?)  # This is an argument
          if (!value['default'].nil?)
            options.string option, value['description'], default:value['default']
          else
            options.string option, value['description']
          end
        else
          throw InvalidTemplateException.new "Inavlid template.json file for #{name}"
        end
      end

      # "Parse" option_files array
      # Forces a spesific structure for this array
      option_files.each do |flag, optionObject|
        if (!optionObject['values'].nil?)   # IF IS ARGUMENT
          values = optionObject['values']   
          raise InvalidTemplateException.new if (!values.is_a?(Hash))

          values.each do |valueKey, files|
            begin
              values[valueKey] = structureFiles(files)
            rescue ArgumentError
              throw new InvalidTemplateException
            end
          end
        elsif (!optionObject['files'].nil?) # IF IS FLAG
          begin
            optionObject['files'] = structureFiles(optionObject['files'])
          rescue ArgumentError
            throw InvalidTemplateException.new
          end
        else
          # Invalid, missing file/values
        end
      end
    end

    # Makes a file hash/array from a template json
    # into a predictable structure
    # For example 
    # [
    #   {
    #     "somefile-src" : "dest",
    #     "someother-src" : "somedest"
    #   },
    #   {
    #     "file-src" : "somesomedest"
    #   },
    #   "filefile"
    # ]
    #
    # will become
    #
    # [
    #   { "somefile-src"  : "dest" },
    #   { "someother-src" : "somedest"},
    #   { "file-src"      : "somesomedest" },
    #   { "filefile"      : "filefile"}
    # ]
    #
    # Or
    # somefile
    # would become
    # [{"somefile":"somefile"}]
    def structureFiles(files)
      if (files.is_a?(String))
        return [{"#{files}"=>"#{files}"}]
      end

      if (files.is_a?(Hash))
        files = [files]
      end

      fail ArgumentError.new unless (files.is_a?(Array))

      structFiles = []
      files.each do |fileObject|
        # File object may be a String or Hash
        if (fileObject.is_a?(String))
          structFiles.push({"#{fileObject}" => "#{fileObject}"})
        elsif (fileObject.is_a?(Hash))
          fileObject.each do |fileSrc, fileDest|
            structFiles.push("#{fileSrc}" => "#{fileDest}")
          end
        else
          fail ArgumentError.new
        end
      end

      return structFiles
    end

    # Create a new "project" base
    # on this template, to the directory
    # "dir".
    def create(args, dir)
      # Make the output dir if
      # it does not exist
      begin
        Dir.mkdir(dir) if (!Dir.exist?(dir))
      rescue SystemCallError => e
        puts e.message
        exit(1)
      end

      # Copy over the static files
      FileUtils.cp_r(path + '/' + static_files + '/.', dir) if (static_files != nil)

      # Copy non static files
      parsedOptions = options.parse(args)
      option_files.each do |flag, object|
        files = {}
        if (!object['values'].nil?)
          values = object['values']
          files = values[parsedOptions[flag]]
          if (files.nil?)
            if (object['require'])
              puts "Missing template argument #{flag}"
              exit(1)
            else
              next
            end
          end
        elsif (!object['files'].nil?)
          if (!parsedOptions[flag])
            if (object['require'])
              puts "Missing template argument #{flag}"
            else
              next
            end
          end
          files  = object['files']
        else
          raise InvalidTemplateException.new
        end

        files.each do |fileHash|
          fileHash.each do |src, dest|
            FileUtils.cp(path + '/' + src, dir + '/' + dest)
          end
        end
      end

      options.each do |key, value|
        option = option_files[key]
        if (!option.nil?)
          filesToCopy = nil
          if (!option['values'].nil?) # Argument
            filesToCopy = option['values'][value]
          elsif (!option['files'].nil?) # Flag
            filesToCopy = option['files']
          else
          end

          filesToCopy.each do |file, outFile|
            FileUtils.cp(path + '/' + file, dir + '/' + outFile)
          end
        end
      end
    end

    # --------- STATIC INTERFACE ----------

    # Create a template object form name
    # Tries to find the template in the
    # include paths spesified in the condif
    # file
    # return nil if the template can no
    # be found
    def self.getTemplateByName(name)
      config = Boot.config
      includePaths = config.templates_path
      path = '';
      includePaths.each { |includePath|
        testPath = includePath + '/' + name;
        if File.directory?(testPath);
          path = testPath;
          break;
        end
      }
      if path == ''
        return nil
      else
        return Template.new(path);
      end
    end
  end
end
