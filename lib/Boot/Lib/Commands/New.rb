include Boot::Lib::Core
include Boot::Lib

module Boot::Lib::Commands
  options_obj = Slop::Options.new suppress_errors: true
  options_obj.string '-o', '--out', 'Spesify where to save the template.', default: File.dirname(__FILE__)
  options_obj.banner = "Usage: boot new 'template-name' [--out 'out-dir'] [-- 'template-options']"

  New = SubCommand.new(
    'new', # Name of the sub command
    'Creates a new project from a template',
    options_obj
  ) { |options, args|
    parsed_options = options.parse(args)

    # The first argument, as long as not a option
    # is the template
    if (!Boot::Lib::Core::SubCommand.is_flag(args[0]))
      template_name = args[0]
    else
      puts options_obj.banner
      next
    end


    output_path = !parsed_options[:out].nil? ? Dir.pwd + '/' + parsed_options[:out] : Dir.pwd

    if (Dir.exists?(output_path) && !(Dir.entries(output_path) - %w{ . .. }).empty?)
      puts "Error: #{output_path} exists and is not empty"
      next # terminate
    end

    if (File.exists?(output_path))
      puts "Error: #{output_path} exists and is a file"
      next # terminate
    end

    # Strip all args before the -- arg, signaling args to the template
    c = 0
    while c < args.length do
      break if (args[c] == '--')
      c+=1
    end
    template_args = args[c+1..-1]
    if (template_args.nil?) # no -- found
      template_args = []
    end

    # Get template by name
    template = Core::Template.get_template_by_name(template_name)
    if template.nil?
      puts "Fatal: Could not find template #{template_name}"
      exit(1)
    end

    # Create a project base on the template
    puts "Creating #{output_path} based on '#{template.name}' template"
    creation_thread = Thread.new {
      begin
        template.create(template_args, output_path)
      rescue ArgumentError => e
        puts e.message
      end
    }
    loading_thread = Thread.new {
      print "Doing stuff"
      while true do
        print ".."
        sleep 0.3
      end
    }
    creation_thread.join
    loading_thread.exit
    puts "\nDone!"
  }
  @New
end
