$opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--debug', GetoptLong::NO_ARGUMENT ],
  [ '--verbose', GetoptLong::NO_ARGUMENT ],
  [ '--dry-run', GetoptLong::NO_ARGUMENT ],
  [ '--quiet', GetoptLong::NO_ARGUMENT ],

  [ '--input-file', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--input-dir', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--output-dir', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--work-dir', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--name', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--version', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--vendor', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--summary', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--description', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--url', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--tag', GetoptLong::REQUIRED_ARGUMENT ],

  [ '--repack', GetoptLong::NO_ARGUMENT ],
  [ '--edit-descriptor', GetoptLong::NO_ARGUMENT ],
  [ '--maintenance', GetoptLong::NO_ARGUMENT ],
  [ '--cimon', GetoptLong::NO_ARGUMENT ],
  [ '--live', GetoptLong::NO_ARGUMENT ],
  [ '--overlay', GetoptLong::NO_ARGUMENT ],
  [ '--stateless', GetoptLong::NO_ARGUMENT ],
  [ '--no-repack', GetoptLong::NO_ARGUMENT ],
  [ '--no-edit-descriptor', GetoptLong::NO_ARGUMENT ],
  [ '--no-maintenance', GetoptLong::NO_ARGUMENT ],
  [ '--no-cimon', GetoptLong::NO_ARGUMENT ],
  [ '--no-live', GetoptLong::NO_ARGUMENT ],
  [ '--no-overlay', GetoptLong::NO_ARGUMENT ],
  [ '--no-stateless', GetoptLong::NO_ARGUMENT ]
)

$deleteYes = nil
$envType = nil

$vars = {}
$noStaticMac = false
$vmPassVars = []

# -- Parse shellscript options
# * +return+: +nil+
# ====== Args
# * +opt+: +string+ - Option name
# * +arg+: +string+ - Value to process
def bin_opts(opt,arg)
#  puts("Parsing: '#{opt}' with value '#{arg}'")
  case opt
    when '--input-file'
      $vibOpts["input_file"] = arg
    when '--input-dir'
      $vibOpts["input_dir"] = arg
    when '--output-dir'
      $vibOpts["output_dir"] = arg
    when '--work-dir'
      $vibOpts["work_dir"] = arg
    when '--name'
      $vibOpts["name"] = arg
    when '--version'
      $vibOpts["version"] = arg
    when '--vendor'
      $vibOpts["vendor"] = arg
    when '--summary'
      $vibOpts["summary"] = arg
    when '--description'
      $vibOpts["description"] = arg
    when '--url'
      $vibOpts["url"] = arg
    when '--tag'
      $vibOpts["tags"].push(arg)
    when '--repack'
      $vibOpts["repack"] = true
    when '--edit-descriptor'
      $vibOpts["edit_descriptor"] = true
    when '--maintenance'
      $vibOpts["maintenance"] = true
    when '--cimon'
      $vibOpts["cimon"] = true
    when '--live'
      $vibOpts["live"] = true
    when '--overlay'
      $vibOpts["overlay"] = true
    when '--stateless'
      $vibOpts["stateless"] = true
    when '--no-repack'
      $vibOpts["repack"] = false
    when '--no-edit-descriptor'
      $edit-descriptor = false
    when '--no-maintenance'
      $vibOpts["maintenance"] = false
    when '--no-cimon'
      $vibOpts["cimon"] = false
    when '--no-live'
      $vibOpts["live"] = false
    when '--no-overlay'
      $vibOpts["overlay"] = false
    when '--no-stateless'
      $vibOpts["stateless"] = false
  end

  if !$vibOpts["input_dir"].nil?
    $vibOpts["repack"] = true
  end
end
