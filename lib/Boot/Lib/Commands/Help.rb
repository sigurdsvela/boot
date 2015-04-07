require 'Boot/Lib/Core/SubCommand.rb';

module Boot::Lib::Commands
	optionsObj = Slop::Options.new;

	Help = Boot::Lib::Core::SubCommand.new(
		"help", #Name of the command
		"Print the help message", #Description
		optionsObj, #Has no options
	) { |options, args|
		Boot::Main.getSubCommands().each do |key, cmd|
			cmd.helpMessage();
		end
	};
	@Help;
end
