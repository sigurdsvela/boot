
#Require sub commands
require 'Boot/Lib/init.rb'

#Include Sub Commands
require 'Boot/Lib/Commands/Help.rb'
require 'Boot/Lib/Commands/New.rb'

module Boot
	class Main
		def self.main
			@subCommands = {};
			@subCommands['help'] = Boot::Lib::Commands::Help;
			@subCommands['new']  = Boot::Lib::Commands::New;

			subCmdObj = @subCommands[ARGV[0].downcase()];

			if (subCmdObj == nil)
				puts "\"#{ARGV[0]}\" is not a sub command. See \"boot help\"";
			else
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
