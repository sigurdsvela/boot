include Boot::Lib::Core

module Boot::Lib::Commands
  options_obj = Slop::Options.new

  Help = SubCommand.new(
    'help', # Name of the command
    'Print the help message', # Description
    options_obj, # Has no options
    false
  ) do |_options, _args|
    Boot.sub_commands.each do |_key, cmd|
      cmd.print_help_message
    end
  end
  @Help
end
