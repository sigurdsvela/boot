require 'Boot/Lib/Core/InvalidTemplateException.rb'
require 'fileutils.rb'

include Boot::Lib::Core

module Boot::Lib::Core
  class Template
  	attr_reader :name
  	attr_reader :description
  	attr_reader :static_file
  	attr_reader :arg_files
  	attr_reader :static_files
  	attr_reader :path

  	#Fields, and there validators
  	@@REQUIRED_FIELDS = {
  		:description => lambda { |value| return value.is_s? },
  		:static      => lambda { |value|
  			# Must be a valid path
  			return value.is_s? && File.directory(value) 
  		}
  	}

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

  		@name = templateConfig['name'];
  		@description = templateConfig['description']
  		@static_files = templateConfig['static']
  		@path = path
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
      puts path + '/' + static_files + ' to ' + dir
		  FileUtils.cp_r(path + '/' + static_files + '/.', dir) if (static_files != nil)
    end

  	# --------- STATIC INTERFACE ----------

  	# Create a template object form name
  	# Tries to find the template in the
  	# include paths spesified in the condif
  	# file
  	# return nil if the template can no
  	# be found
    def self.getTemplateByName(name)
      config = Boot::Main.config
      includePaths = config.template_include_paths
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
