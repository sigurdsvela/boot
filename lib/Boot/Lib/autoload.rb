module Boot end
module Boot::Lib end

module Boot::Lib::Core
  autoload :Config, File.dirname(__FILE__) + "/Core/Config.rb"
  autoload :InvalidConfigFile, File.dirname(__FILE__) + "/Core/InvalidConfigFile.rb"
  autoload :InvalidTemplateFile, File.dirname(__FILE__) + "/Core/InvalidTemplateFile.rb"
  autoload :SubCommand, File.dirname(__FILE__) + "/Core/SubCommand.rb"
  autoload :Template, File.dirname(__FILE__) + "/Core/Template.rb"
end

module Boot::Lib::Commands
  autoload :New, File.dirname(__FILE__) + "/Commands/New.rb"
  autoload :Help, File.dirname(__FILE__) + "/Commands/Help.rb"
end
