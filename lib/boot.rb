require_relative 'Boot/Lib/autoload.rb'
require 'JSON'

module Boot
  VERSION = "0.3.1"

  def self.main
    # Open and parse default config
    default_config_file_path = File.dirname(__FILE__) + '/boot-default-config.json'
    default_config_object = JSON.parse(File.open(default_config_file_path, "rb").read)
    
    # Open and barse .boot file
    dot_config_file_path = File.expand_path('~/.boot')
    dot_config_object = {}
    if (File.exists?(dot_config_file_path))
      dot_config_file = File.open(dot_config_file_path, "rb")
      dot_config_object = JSON.parse(dot_config_file.read)
    end

    # Merge default and .boot
    config_object = default_config_object.merge(dot_config_object)

    begin
      @config = Boot::Lib::Core::Config.new(config_object)
    rescue Boot::Lib::Core::InvalidConfigException => e
      puts e.message
      exit
    end

    @sub_commands = {}
    @sub_commands['help'] = Boot::Lib::Commands::Help
    @sub_commands['new']  = Boot::Lib::Commands::New
    @sub_commands['config']  = Boot::Lib::Commands::Config
    @sub_commands['version']  = Boot::Lib::Commands::Version
    @sub_commands['template']  = Boot::Lib::Commands::Template

    if ARGV[0] == nil
      Boot::Lib::Commands::Help.run([]);
    elsif @sub_commands[ARGV[0]].nil?
      puts "'#{ARGV[0]}' is not a sub command. See 'boot help'"
    else
      subCmdObj = @sub_commands[ARGV[0].downcase]
      ARGV.shift; # Remove subcommand from ARGV, rest is options
      subCmdObj.run(ARGV)
    end
  end

  def self.dir
    File.dirname(File.expand_path(__FILE__))
  end

  def self.config
    return @config
  end

  #attr_reader :sub_commands
  def self.sub_commands
    return @sub_commands
  end
end