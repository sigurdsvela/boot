
# Require sub commands
require 'Boot/Lib/autoload.rb'

require 'Boot/Lib/Core/Config.rb'
require 'Boot/Lib/Core/InvalidConfigException.rb'

# Include Sub Commands
require 'Boot/Lib/Commands/Help.rb'
require 'Boot/Lib/Commands/New.rb'

module Boot
  VERSION = "0.1.0"

  def self.main
    configFilePath = File.dirname(__FILE__) + '/boot-config.json'

    begin
      @config = Boot::Lib::Core::Config.new(configFilePath)
    rescue Boot::Lib::Core::InvalidConfigException => e
      puts e.message
      exit
    end

    @subCommands = {}
    @subCommands['help'] = Boot::Lib::Commands::Help
    @subCommands['new']  = Boot::Lib::Commands::New
    @subCommands['config']  = Boot::Lib::Commands::Config

    if ARGV[0] == nil
      Boot::Lib::Commands::Help.run([]);
    elsif @subCommands[ARGV[0]].nil?
      puts "'#{ARGV[0]}' is not a sub command. See 'boot help'"
    else
      subCmdObj = @subCommands[ARGV[0].downcase]
      ARGV.shift; # Remove subcommand from ARGV, rest is options
      subCmdObj.run(ARGV)
    end
  end

  def self.config
    return @config
  end

  def self.getSubCommands
    @subCommands
  end
end
Boot.main
