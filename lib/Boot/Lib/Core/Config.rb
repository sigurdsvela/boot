require 'JSON';
require 'Boot/Lib/Core/InvalidConfigException.rb'

module Boot::Lib::Core
	class Config
		#Initilize with path to config file
		def initialize(path)
			@filePath = path;
			@file = File.open(path, "rb");
			content = @file.read();
			@config = JSON.parse(content);
			@templatesDir = @config['templates-dir'];

			#If templates-dir is not defined
			if (@templatesDir == nil)
				msg = "";
				msg << "Invalid config file: templates-dir not defined\n";
				msg << "Please set this to the directory(s) where your\n";
				msg << "templates are located\n";
				raise Boot::Lib::Core::InvalidConfigException.new(msg);
			end

			#If template dir is defined, but invalid path
			if (!@templatesDir.is_a?(Array) && !File.directory?(@templatesDir))
				msg = "";
				msg << "Invalid config file: templates-dir is not a directory\n";
				msg << "Please set this to the directory(s) where your\n";
				msg << "templates are located\n";
				raise Boot::Lib::Core::InvalidConfigException.new(msg);
			end

			#If template dit is an array
			if (@templatesDir.is_a?(Array))
				notDirs = [];
				
				#Add each path that is invalid to notDirs
				@templatesDir.each do |path|
					if (!File.directory? path)
						notDirs.push(path);
					end
				end

				#If any element in notDirs, invalid config
				if (notDirs.length > 0)
					msg = "";
					msg << "Invalid config file:\n";
					msg << "the path(s): " + notDirs.join(", ") + "\n";
					msg << "Are not directories\n";
					raise Boot::Lib::Core::InvalidConfigException.new(msg);
				end
			end

		end

		def getTemplateIncludePaths()
		end
	end
end