include Boot::Lib::Core

module Boot::Lib::Commands
  optionsObj = Slop::Options.new
  optionsObj.string '-t', '--template', 'Spesify template to use'
  optionsObj.string '-o', '--out', 'Spesify where to save the template.', default: File.dirname(__FILE__)

  New = SubCommand.new(
    'new', # Name of the sub command
    'Creates a new project from a template',
    optionsObj
  ) { |options, args|
    parsedOptions = options.parse(args)
    
    templateName = parsedOptions[:template]
    outputPath = !parsedOptions[:out].nil? ? Dir.pwd + '/' + parsedOptions[:out] : Dir.pwd

    if templateName.nil?
      puts "'boot new' requires the --template [string] option"
    end

    # Get template by name
    template = Template.getTemplateByName(templateName)
    if template.nil?
      puts "Fatal: Could not find template #{templateName}"
      exit(1)
    end

    # Create a project base on the template
    template.create(args, outputPath)
  }
  @New
end
