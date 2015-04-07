
#Require sub commands
require 'Boot/Lib/init.rb'

require 'Boot/Lib/Core/Config.rb'
require 'Boot/Lib/Core/InvalidConfigException.rb'

#Include Sub Commands
require 'Boot/Lib/Commands/Help.rb'
require 'Boot/Lib/Commands/New.rb'

module Boot
	class Main
		def self.main
			configFilePath = File.dirname(__FILE__) + "/boot-config.json";

			begin
				@config = Boot::Lib::Core::Config.new(configFilePath);
			rescue Boot::Lib::Core::InvalidConfigException => e
				puts e.message
				exit();
			end

			@subCommands = {};
			@subCommands['help'] = Boot::Lib::Commands::Help;
			@subCommands['new']  = Boot::Lib::Commands::New;

			if (subCmdObj == nil)
				puts "\"#{ARGV[0]}\" is not a sub command. See \"boot help\"";
			else
				subCmdObj = @subCommands[ARGV[0].downcase()];
				ARGV.shift(); #Remove subcommand from ARGV, rest is options
				subCmdObj.run(ARGV);
			end
		end

		def self.getSubCommands
			return @subCommands;
		end
	end

	Main.main;
end
