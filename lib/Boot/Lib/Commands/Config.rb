include Boot::Lib::Core

module Boot::Lib::Commands
  optionsObj = Slop::Options.new
  optionsObj.on "--all", "Print all config options. Can not be used with any other arguments."
  
  Config = SubCommand.new(
    'config', # Name of the sub command
    'Read or set configuration options',
    optionsObj
  ) { |options, args|
    parsedOptions = options.parse(args);
    if (!parsedOptions[:all])
      optionName = args[0]
      optionVal = Boot::Main.config.config[optionName]
      if (optionVal == nil)
        puts "No option '#{optionName}'"
      else
        puts "#{optionName} = #{optionVal}"
      end
    else
      puts Boot::Main.config.config
    end
  }
  @Config
end
