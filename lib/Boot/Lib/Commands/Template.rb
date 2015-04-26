include Boot::Lib::Core
include Boot::Lib

require 'JSON'

module Boot::Lib::Commands
  optionsObj = Slop::Options.new
  optionsObj.on "--list", "List all template names"
  
  Template = SubCommand.new(
    'template', # Name of the sub command
    'Print info for a template',
    optionsObj
  ) { |options, args|
    parsedOptions = options.parse(args)
    if (parsedOptions[:list])
      templates = {}

      Boot.config.templates_path.each do |dir|
        Dir[dir + "/*"].each do |template_path|
          name = template_path.split('/')[-1]
          if (templates[name].nil?)
            templates[name] = Core::Template.getTemplateByName(name)
          end
        end
      end

      templates.each do |key, value|
        puts "name:     " + value.name
        puts "location: " + value.path
        puts "description:\n"
        puts value.description
        puts
      end

      next
    end

    if (args.length != 1)
      puts "usage 'boot template [template name]'"
    end

    template_name = args[0]
    template = Core::Template.getTemplateByName(template_name)

    if (template.nil?)
      puts "Could not find template '#{template_name}'"
    else
      msg = ''
      msg << 'Template:    ' + template.name + "\n"
      msg << 'Description: ' + template.name + "\n"
      msg << 'Location:    ' + template.path + "\n"
      msg << "\nOptions\n"
      
      template.option_files.each do |key, value|
        msg << key
        msg << ' '

        if (!value['values'].nil?)
          msg << '['
          value['values'].each do |key,value|
            msg << "#{key}/"
          end
          msg = msg[0..-2] # Remove the last /
          msg << "]\n"
        else
          fail if (value['files'].nil?) # Assertion
          msg << "\n"
        end
        msg << "\t" + value['description']
        msg << "\n\n"

      end

      puts msg
    end
  }
  @Template
end
