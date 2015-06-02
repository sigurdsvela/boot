include Boot::Lib::Core

require 'JSON'

module Boot::Lib::Commands
  options_obj = Slop::Options.new
  options_obj.on "--all", "Print all config options. Can not be used with any other arguments."
  
  Config = SubCommand.new(
    'config', # Name of the sub command
    'Read configuration options',
    options_obj
  ) { |options, args|
    parsed_options = options.parse(args);
    if (!parsed_options[:all])
      option_name = args[0]
      option_val = Boot.config.config[option_name]
      if (option_val == nil)
        puts "No option '#{option_name}'"
      else
        puts "#{option_name} = #{option_val}"
      end
    else
      puts JSON.pretty_generate(Boot.config.config)
    end
  }
  @Config
end
