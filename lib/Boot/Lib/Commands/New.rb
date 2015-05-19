include Boot::Lib::Core
include Boot::Lib

module Boot::Lib::Commands
  optionsObj = Slop::Options.new suppress_errors: true
  optionsObj.string '-t', '--template', 'Spesify template to use'
  optionsObj.string '-o', '--out', 'Spesify where to save the template.', default: File.dirname(__FILE__)

  New = SubCommand.new(
    'new', # Name of the sub command
    'Creates a new project from a template',
    optionsObj
  ) { |options, args|
    parsedOptions = options.parse(args)
    
    templateName = parsedOptions[:template]
    # If template not defined, and first arg is not a option
    # it is the template name
    if (templateName.nil? && !Boot::Lib::Core::SubCommand.is_flag(args[0]))
      templateName = args[0]
    end

    outputPath = !parsedOptions[:out].nil? ? Dir.pwd + '/' + parsedOptions[:out] : Dir.pwd
    
    # Strip all args before the -- arg, signaling args to the template
    c = 0
    while c < args.length do
      break if (args[c] == '--')
      c+=1
    end
    templateArgs = args[c+1..-1]
    if (templateArgs.nil?) # no -- found
      templateArgs = []
    end

    if templateName.nil?
      puts "'boot new' requires the --template [string] option"
    end

    # Get template by name
    template = Core::Template.getTemplateByName(templateName)
    if template.nil?
      puts "Fatal: Could not find template #{templateName}"
      exit(1)
    end

    # Create a project base on the template
    puts "Creating #{outputPath} base on '#{template.name}' template"
    creation_thread = Thread.new {
      template.create(templateArgs, outputPath)
    }
    loading_thread = Thread.new {
      print "Doing stuff"
      while true do
        print "."
        sleep 0.3
      end
    }
    creation_thread.join
    loading_thread.exit
    print "\n"
  }
  @New
end
