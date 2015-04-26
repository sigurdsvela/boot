include Boot::Lib::Core

require 'JSON'

module Boot::Lib::Commands
  optionsObj = Slop::Options.new
  optionsObj.on "--all", "Print all config options. Can not be used with any other arguments."
  
  Config = SubCommand.new(
    'config', # Name of the sub command
    'Read configuration options',
    optionsObj
  ) { |options, args|
    parsedOptions = options.parse(args);
    if (!parsedOptions[:all])
      optionName = args[0]
      optionVal = Boot.config.config[optionName]
      if (optionVal == nil)
        puts "No option '#{optionName}'"
      else
        puts "#{optionName} = #{optionVal}"
      end
    else
      puts JSON.pretty_generate(Boot.config.config)
    end
  }
  @Config
end
