include Boot::Lib::Core

module Boot::Lib::Commands
  optionsObj = Slop::Options.new
  
  Version = SubCommand.new(
    'version', # Name of the sub command
    'Print the version',
    optionsObj
  ) { |options, args|
    puts Boot::VERSION
  }
  @Version
end
