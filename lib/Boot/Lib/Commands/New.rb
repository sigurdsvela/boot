require 'Boot/Lib/Core/SubCommand.rb';
require 'Boot/Lib/Core/Template.rb';

module Boot::Lib::Commands
	optionsObj = Slop::Options.new;
	optionsObj.string "-t", "--template", "Spesify template to use";
	optionsObj.string "--out", "Spesify where to save the template.", default:File.dirname(__FILE__);

	New = Boot::Lib::Core::SubCommand.new(
		"new", #Name of the sub command
		"Creates a new project form a template",
		optionsObj,
	) { |options,args|
		templateName = options.parse(args)["-t"];
		if (templateName == nil)
			puts "\"boot new\" requires the --template [string] option";
		end

		#Get template by name
		template = Boot::Lib::Core::Template.getTemplateByName(templateName);
		if (template == nil)
			puts "Fatal: Could not find template #{templateName}"
		end
	}
	@New
end
