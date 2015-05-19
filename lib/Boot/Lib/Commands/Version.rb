include Boot::Lib::Core

module Boot::Lib::Commands
  options_obj = Slop::Options.new
  
  Version = SubCommand.new(
    'version', # Name of the sub command
    'Print the version',
    options_obj,
    false
  ) { |options, args|
    puts Boot::VERSION
  }
  @Version
end
