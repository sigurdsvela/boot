module Boot::Lib::Core
	class SubCommand
		attr_reader :name;
		attr_reader :description;
		attr_reader :options;

		def initialize(name, description, options, &block)
			@name        = name;
			@description = description;
			@options     = options;
			@block       = block;
		end

		def run(args)
			begin
				@options.parse(args); #Dryrun to check for argument errors
				@block.call(@options, args);
			rescue Slop::UnknownOption => e
				#Hack to get around the lack of e.getUnknownOption()
				#TODO Fix once avaiable
				if (e.message[-7..-2] == "--help")
					printHelpMessage();
				else
					puts "#{e.message}. Try boot #{@name} --help";
				end
			end
		end

		def printHelpMessage()
			puts "boot " + @name;
			if (@description != "")
				puts "\tDescription:";
				puts "\t" + @description;
			end
			if (@options.options.length > 0)
				puts
				puts "\tArguments:"
				@options.each { |a|
					print "\t" + '%-16.16s' % (a.flags*", ");
					print "\t";
					print a.desc + "\n";
				}
			end
			puts
		end
	end
end