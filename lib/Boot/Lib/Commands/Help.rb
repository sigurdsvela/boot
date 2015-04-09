require 'Boot/Lib/Core/SubCommand.rb'

module Boot::Lib::Commands
  optionsObj = Slop::Options.new

  Help = Boot::Lib::Core::SubCommand.new(
    'help', # Name of the command
    'Print the help message', # Description
    optionsObj, # Has no options
  ) do |_options, _args|
    Boot::Main.getSubCommands.each do |_key, cmd|
      cmd.printHelpMessage
    end
  end
  @Help
end
