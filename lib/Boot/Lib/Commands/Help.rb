include Boot::Lib::Core

module Boot::Lib::Commands
  optionsObj = Slop::Options.new

  Help = SubCommand.new(
    'help', # Name of the command
    'Print the help message', # Description
    optionsObj, # Has no options
    false
  ) do |_options, _args|
    Boot.getSubCommands.each do |_key, cmd|
      cmd.printHelpMessage
    end
  end
  @Help
end
