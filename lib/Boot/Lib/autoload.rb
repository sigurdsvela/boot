require 'slop'

module Boot end
module Boot::Lib end

module Boot::Lib::Core
  autoload :Config, File.dirname(__FILE__) + "/Core/Config.rb"
  autoload :InvalidConfigException, File.dirname(__FILE__) + "/Core/InvalidConfigException.rb"
  autoload :InvalidTemplateException, File.dirname(__FILE__) + "/Core/InvalidTemplateException.rb"
  autoload :SubCommand, File.dirname(__FILE__) + "/Core/SubCommand.rb"
  autoload :Template, File.dirname(__FILE__) + "/Core/Template.rb"
end

module Boot::Lib::Commands
  autoload :New, File.dirname(__FILE__) + "/Commands/New.rb"
  autoload :Help, File.dirname(__FILE__) + "/Commands/Help.rb"
  autoload :Config, File.dirname(__FILE__) + "/Commands/Config.rb"
  puts 'Register autoload for Version'
  autoload :Version, File.dirname(__FILE__) + "/Commands/Version.rb"
end
