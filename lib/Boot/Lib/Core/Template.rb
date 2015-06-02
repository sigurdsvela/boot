require 'fileutils.rb'
require 'json-schema'
require 'JSON'

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

    # Symbols
    # {
    #   "--flag" : {
    #     "symbol"   : "name"
    #     "required" : true/false
    #     "default"  : "" //Not present if require is true
    #   }
    # }
    attr_reader :symbols

    attr_reader :template_options

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

      templateJsonFile = File.open(path + "/template.json", "r")
      templateConfig = JSON.parse(templateJsonFile.read)
      templateJsonFile.close

      templateJsonSchemaFile = File.open(Boot::LIB_PATH + '/template.json-schema', "r")
      templateJsonSchema = JSON.parse(templateJsonSchemaFile.read)
      templateJsonSchemaFile.close

      errors = JSON::Validator.fully_validate(templateJsonSchema, templateConfig)
      if (errors.length > 0)
        msg = ''
        msg << 'Invalid template.json file for '
        msg << "#{name} template in #{path}\n"
        msg << errors * "\n"

        fail InvalidTemplateException.new msg
      end

      @name = templateConfig['name'];
      @description = templateConfig['description']
      @static_files = templateConfig['static']

      if ((!static_files.is_a?(Array)) && (!static_files.nil?))
        @static_files = [@static_files]
      end

      @path = path
      @template_options = templateConfig['options']
      @template_options = {} if @template_options.nil?

      @options = Slop::Options.new

      options.banner = "usage: #{$0} new --template #{name} [--out DIR] [options]"

      # Validate static folders
      @static_files.each do |static_dir_path|
        msg = ''
        static_dir_path = path + '/' + static_dir_path
        if (!File.exist?(static_dir_path) || File.file?(static_dir_path))
          msg << "static: #{static_dir_path} is not a directory\n"
        end
        if (msg != '')
          fail InvalidTemplateException.new msg
        end
      end

      # Create slop option object
      template_options.each do |option, value|
        if (!value['files'].nil?) # This is a flag
          options.on option, value['description']
        elsif ((!value['values'].nil?) || (!value['symbol'].nil?))  # This is an argument
          if (!value['default'].nil?)
            options.string option, value['description'], default:value['default']
          else
            options.string option, value['description']
          end
        else
          throw InvalidTemplateException.new "Inavlid template.json file for #{name}"
        end
      end
      
      # Parse out the symbols
      @option_files = template_options.clone
      @symbols = {}
      template_options.each do |key, value|
        if (!value['symbol'].nil?)
          # Remove from option_files, this is a symbol
          option_files.delete(key)
          symbols[key] = {}
          
          symbols[key]['symbol'] = value['symbol']
          if (!value['default'].nil?)
            symbols[key]['require'] = false
            symbols[key]['default'] = value['default']
          else
            symbols[key]['require'] = true
          end
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
              values[valueKey] = Template.structure_files(files)
            rescue ArgumentError
              throw new InvalidTemplateException
            end
          end
        elsif (!optionObject['files'].nil?) # IF IS FLAG
          begin
            optionObject['files'] = Template.structure_files(optionObject['files'])
          rescue ArgumentError
            throw InvalidTemplateException.new
          end
        else
          # Invalid, missing file/values
        end
      end
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
      
      # Parse the arguments
      parsedOptions = options.parse(args)

      defined_symbols = {}
      symbols.each do |flag, object|
        if (!parsedOptions[flag].nil?)
          defined_symbols[object['symbol']] = parsedOptions[flag]
        elsif (object['require']) # Not defined and required
          fail ArgumentError.new "Must define '#{flag}' for '#{name}' template"
        end
      end


      # Copy over the static files
      if (!static_files.nil?)
        static_files.each do |static_files_path|
          static_file_base = path + '/' + static_files_path
          Dir[static_file_base + '/**/*'].each do |file_path|
            # Do not copy dummy files
            next if (File.basename(file_path) == "___dummy-file___")
            
            file_name = file_path[static_file_base.length..-1]
            file_name = replace_symbols(file_name, defined_symbols)
            if (File.directory?(file_path))
              FileUtils.mkdir dir + file_name unless File.exist? dir + file_name
            else
              FileUtils.cp(file_path, dir + file_name)
            end
          end
        end
      end

      # Copy non static files
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
            dest = replace_symbols(dest, defined_symbols)
            FileUtils.cp(path + '/' + src, dir + '/' + dest)
          end
        end
      end

      options.each do |key, value|
        option = option_files[key]
        if (!option.nil?)
          files_to_copy = nil
          if (!option['values'].nil?) # Argument
            files_to_copy = option['values'][value]
          elsif (!option['files'].nil?) # Flag
            files_to_copy = option['files']
          else
          end

          files_to_copy.each do |file, out_file|
            out_file = replace_symbols(out_file, defined_symbols)
            FileUtils.cp(path + '/' + file, dir + '/' + out_file)
          end
        end
      end

      # Replace symbols in content of files
      Dir.glob(dir + "/**/*").each do |file|
        next unless File.file? file
        file_object_r = File.open(file, "r")
        file_content = file_object_r.read
        file_object_r.close
        file_object_w = File.open(file, "w")

        # If this doesent work, dont stress
        # Probably just not an UTF-8 text file error
        begin
          file_object_w.write replace_symbols(file_content, defined_symbols)
        rescue ArgumentError => e
          file_object_w.close
          next
        end
        file_object_w.close
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
    def self.structure_files(files)
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

    def replace_symbols(string, findReplace)
      findReplace.each do |find, replace|
        string = string.gsub("[[!" + find + "]]", replace)
      end
      return string
    end

    # --------- STATIC INTERFACE ----------

    # Create a template object form name
    # Tries to find the template in the
    # include paths spesified in the condif
    # file
    # return nil if the template can no
    # be found
    def self.get_template_by_name(name)
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
