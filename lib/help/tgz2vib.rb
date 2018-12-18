$extraopts_usage = '[(--input-file "/path/to/input.tgz" | --input-dir "/path/to/input/")] [--output-dir "/path/to/output" ] [--work-dir "/path/to/workdir" ] [--name "custom-myvib"] [--version "1.0.0-1" ] [--vendor "Me_Myself_I"] [--summary "My Vib Does things"] [--description "My VIB"] [--url https://path/to/repo/issue ] [--tag mytag] (--(no-)repack) (--(no-)edit-descriptor) (--(no-)maintenance) (--(no-)cimon) (--(no-)live) (--(no-)overlay) (--(no-)stateless)'

$extraopts_descriptions = {
  '--input-file' => 'Input Tgz file of directory structure',
  '--input-dir' => 'Directory structure to create Tgz from; implies --repack',
  '--output-dir' => 'Path to output created vib (and repacked tgz, when --repack set)',
  '--work-dir' => 'Path for work processes (temp directory)',
  '--name' => 'Name of the VIB to create (EX: custom-myspecialvib)',
  '--version' => 'Version of the vib, EX: 1.0.1',
  '--vendor' => 'The vendor of the content, (EX: Intel)',
  '--summary' => 'Short description of VIB',
  '--description' => 'Long Description of VIB',
  '--url' => 'KB / Issue / Git url',
  '--tag' => 'Software tags, use multiple times for multiple tags',
  '--(no-)repack' => 'Set/Unset Repack (will extract, then repack input file; May cause permissions loss)',
  '--(no-)edit-descriptor' => 'Set/Unset pause to edit descriptor.xml file',
  '--(no-)maintenance' => 'Set/Unset maintenance mode requirement for VIB installation',
  '--(no-)cimon' => 'Set/Unset cimon restart requirement for VIB installation',
  '--(no-)live' => 'Set/Unset live install/uninstall allowance for VIB installation',
  '--(no-)overlay' => 'Set/Unset overlay allowance for VIB',
  '--(no-)stateless' => 'Set/Unset VIB statefulness',
}

