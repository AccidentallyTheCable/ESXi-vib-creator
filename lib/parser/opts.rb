require_relative "common.rb"

$verbose = false
$debug = 0

def printhelp()
  $extraopts_usage = nil
  $extraopts_descriptions = []
  extrafile = "#{$base_dir}/lib/help/#{$myCommandName}.rb"
  puts("Load help: #{extrafile}")
  if File.exist?(extrafile)
    require extrafile
  end
  puts("#{$myCommandName}: #{$myCommandDescription}\n")
  puts("Usage: #{$myCommandName} (-h|--help) ((-v|--verbose)|(-d|--debug)) (-D|--dry-run) #{$extraopts_usage}\n")
  puts("Required Options:\n")
  puts("Command Specific Options:\n")
  if File.exist?(extrafile)
    $extraopts_descriptions.each do |arg,desc|
      puts("\t#{arg}\t\t#{desc}\n")
    end
  end
  puts("Additional Options:\n")
  puts("\t-h|--help\t\tThis help message\n")
  puts("\t-v|--verbose\t\tTurn on Verbose mode\n")
  puts("\t-d|--debug\t\tTurn on Debug mode\n")
  puts("\t-D|--dry-run\t\tDo not actually do things, just say what would be done\n")
  puts("\n")
  end_process 1
end


def parse_opts()
  if ARGV.length == 0
    printhelp()
    false
  end
  begin
    extraopts = "#{$base_dir}/lib/parser/opts/#{$myCommandName}.rb"
    if File.exist?(extraopts)
      load extraopts
    end
    if $opts.nil?
      $opts = GetoptLong.new(
          [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
          [ '--debug', GetoptLong::NO_ARGUMENT ],
          [ '--quiet', GetoptLong::NO_ARGUMENT ],
          [ '--verbose', GetoptLong::NO_ARGUMENT ],
          [ '--dry-run', GetoptLong::NO_ARGUMENT ]
      )
    end
    $opts.each do |opt,arg|
      if defined? :bin_opts
        bin_opts(opt,arg)
      end
      case opt
        when '--help'
          printhelp()
        when '--verbose'
          $verbose = true
      end
    end
  rescue GetoptLong::MissingArgument, GetoptLong::InvalidOption => error
    printhelp()
  end
  true
end

