include Boot::Lib::Core
include Boot::Lib

module Boot::Lib::Commands
  optionsObj = Slop::Options.new suppress_errors: true
  optionsObj.string '-o', '--out', 'Spesify where to save the template.', default: File.dirname(__FILE__)
  optionsObj.banner = "Usage: boot new 'template-name' [--out 'out-dir'] [-- 'template-options']"

  New = SubCommand.new(
    'new', # Name of the sub command
    'Creates a new project from a template',
    optionsObj
  ) { |options, args|
    parsedOptions = options.parse(args)

    # The first argument, as long as not a option
    # is the template
    if (!Boot::Lib::Core::SubCommand.is_flag(args[0]))
      templateName = args[0]
    else
      puts optionsObj.banner
      next
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

    # Get template by name
    template = Core::Template.getTemplateByName(templateName)
    if template.nil?
      puts "Fatal: Could not find template #{templateName}"
      exit(1)
    end

    # Create a project base on the template
    puts "Creating #{outputPath} base on '#{template.name}' template"
    creation_thread = Thread.new {
      begin
        template.create(templateArgs, outputPath)
      rescue ArgumentError => e
        puts e.message
      end
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
