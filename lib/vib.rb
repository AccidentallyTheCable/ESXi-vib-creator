require "fileutils"

class VibAuthor

  @@vibOptions = {}
  @@vibDirs = {}

  @@vibData = {}

  def initialize(vibData)
    @@vibOptions = vibData
    @@vibDirs["work"] = @@vibOptions["work_dir"]
    @@vibDirs["oem"] = "#{@@vibDirs["work"]}/oem/"
    @@vibDirs["tmp"] = "#{@@vibDirs["work"]}/tmp/"
    @@vibDirs["vib"] = "#{@@vibDirs["work"]}/vib/"

    vibName = @@vibOptions["name"]
    @@vibData["name"] = vibName[0,8]

  end

  def run()
    print_out("Building VIB package!")
    if $verbose
      print_out("Running with options:")
      @@vibOptions.each do |k,v|
        print_out(" - #{k} = '#{v}'")
      end
    end
    self.mktempdir
    self.copyinput
    self.repack_a
    self.checksum_a
    self.repack_b
    t = Time.now
    @@vibData["release_date"] = t.strftime("%Y-%m-%dT%H:%M:%S.000000+00:00")
    FileUtils.copy("#{@@vibDirs["tmp"]}/oem.tgz", "#{@@vibDirs["vib"]}/#{@@vibData["name"]}")
    @@vibData["size"] = File.size?("#{@@vibDirs["vib"]}/#{@@vibData["name"]}")
    self.checksum_b
    self.descriptor
    self.signvib

    if @@vibOptions["edit_descriptor"]
      print_out("Pausing to edit descriptor.xml")
      system("$EDITOR #{@@vibDirs["vib"]}/descriptor.xml")
      print_out("Editor exited")
    end

    self.createvib

    print_out("VIB Created! Location: #{@@vibData["vibfile"]}")
  end

  def createvib()
    @@vibData["vibfile"] = "#{@@vibDirs["work"]}/#{@@vibData["name"]}-#{@@vibOptions["version"]}.x86_64.vib"
    if File.exist?(@@vibData["vibfile"])
      print_out("File: #{@@vibData["vibfile"]} already exists, will be deleted and re-created")
      FileUtils.rm(@@vibData["vibfile"])
    end
    print_out("Adding signature and descriptor to VIB")
    exec_local("cd #{@@vibDirs["vib"]} && ar qDv #{@@vibData["vibfile"]} descriptor.xml sig.pkcs7 #{@@vibDirs["vib"]}/#{@@vibData["name"]}",true,true)
  end

  def signvib()
    print_out("Creating Empty signature file")
    exec_local("touch #{@@vibDirs["vib"]}/sig.pkcs7",false,false)
  end

  def descriptor()
    print_out("Creating descriptor.xml")
    dsHandle = File.open("#{@@vibDirs["vib"]}/descriptor.xml","w")
    
    dsHandle.write("<vib version=\"5.0\"><type>#{@@vibOptions["type"]}</type>")
    dsHandle.write("<name>#{@@vibData["name"]}</name>")
    dsHandle.write("<version>#{@@vibOptions["version"]}</version>")
    dsHandle.write("<vendor>#{@@vibOptions["vendor"]}</vendor>")
    dsHandle.write("<summary>#{@@vibOptions["summary"]}</summary>")
    dsHandle.write("<description>#{@@vibOptions["description"]}</description>")
    dsHandle.write("<release-date>#{@@vibData["release_date"]}</release-date>")

    if @@vibOptions["url"].nil?
      dsHandle.write("<urls/>")
    else
      dsHandle.write("<urls><url key=\"kb\">#{@@vibOptions["url"]}</url></urls>")
    end

    dsHandle.write("<relationships>")
    if @@vibOptions["depends"].nil?
      dsHandle.write("<depends/>")
    elsif @@vibOptions["depends"].size > 0
      dsHandle.write("<depends>")
      @@vibOptions["depends"].each do |dep|
        dsHandle.write("<constraint name=\"#{dep}\"/>")
      end
      dsHandle.write("</depends>") 
    else
      dsHandle.write("<depends/>")
    end
    dsHandle.write("<conflicts/>")
    dsHandle.write("<replaces/>")
    dsHandle.write("<provides/>")
    dsHandle.write("<compatibleWith/>")
    dsHandle.write("</relationships>")

    if @@vibOptions["tags"].count > 0
      dsHandle.write("<software-tags>")
      @@vibOptions["tags"].each do |tag|
        dsHandle.write("<tag>#{tag}</tag>")
      end
      dsHandle.write("</software-tags>") 
    else
      dsHandle.write("<software-tags/>")
    end

    dsHandle.write("<system-requires>")
    dsHandle.write("<maintenance-mode>#{@@vibOptions["maintenance"]}</maintenance-mode>")
    dsHandle.write("</system-requires>")

    dsHandle.write("<file-list>")
    @@vibData["files"].each do |f|
      dsHandle.write("<file>#{f}</file>")
    end
    dsHandle.write("</file-list>")

    dsHandle.write("<acceptance-level>#{@@vibOptions["acceptance_level"]}</acceptance-level>")

    dsHandle.write("<live-install-allowed>#{@@vibOptions["live"]}</live-install-allowed>")
    dsHandle.write("<live-remove-allowed>#{@@vibOptions["live"]}</live-remove-allowed>")

    dsHandle.write("<cimon-restart>#{@@vibOptions["cimon"]}</cimon-restart>")

    dsHandle.write("<stateless-ready>#{@@vibOptions["stateless"]}</stateless-ready>")

    dsHandle.write("<overlay>#{@@vibOptions["overlay"]}</overlay>")

    dsHandle.write("<payloads>")
    dsHandle.write("<payload name=\"#{@@vibData["name"]}\" type=\"tgz\" size=\"#{@@vibData["size"]}\">")
    if @@vibOptions["checksum"]
      dsHandle.write("<checksum checksum-type=\"sha-256\">#{@@vibData["PayloadChecksum_256"]}</checksum>")
      dsHandle.write("<checksum checksum-type=\"sha-1\">#{@@vibData["PayloadChecksum_1"]}</checksum>")
    end
    dsHandle.write("</payload>")
    dsHandle.write("</payloads>")

    dsHandle.write("</vib>")
    dsHandle.close()
  end

  def checksum_b()
    if @@vibOptions["checksum"]
      cs = exec_local("sha256sum #{@@vibDirs["tmp"]}/#{@@vibOptions["name"]}.tgz",true,true)
      csHandle = File.open("#{@@vibDirs["tmp"]}/sha256sum.tmp","w")
      csHandle.write(cs)
      csHandle.close
      @@vibData["PayloadChecksum_256"] = cs
    end
  end

  def checksum_a()
    if @@vibOptions["checksum"]
      print_out("Calculating Checksum of OEM.tar")
      cs = exec_local("sha1sum #{@@vibDirs["tmp"]}/oem.tar",true,true)
      csHandle = File.open("#{@@vibDirs["tmp"]}/sha1sum.tmp","w")
      csHandle.write(cs)
      csHandle.close
      @@vibData["PayloadChecksum_1"] = cs
    end
  end

  def repack_b()
    if @@vibOptions["repack"]
      print_out("Recompressing OEM.tar")
      exec_local("gzip -c #{@@vibDirs["tmp"]}/oem.tar > #{@@vibDirs["tmp"]}/oem.tgz",false,false)
    end
  end

  def repack_a()
    if @@vibOptions["repack"]
      if @@vibOptions["input_type"] == 0
        if File.exist?("#{@@vibDirs["tmp"]}/oem.tar")
          print_out("Deleting Old OEM tarball")
          FileUtils.rm("#{@@vibDirs["tmp"]}/oem.tar")
        end
      end
      print_out("Creating new OEM.tgz")
      exec_local("cd #{@@vibDirs["oem"]} && tar -cf #{@@vibDirs["tmp"]}/oem.tar *",false,true)
    end
  end

  def copyinput()
    if @@vibOptions["input_type"] == 0
      print_out("Copying #{@@vibOptions["input_file"]} and unzipping (gunzip)")
      FileUtils.copy(@@vibOptions["input_file"],"#{@@vibDirs["tmp"]}/oem.tgz")
      exec_local("cd #{@@vibDirs["tmp"]} && gunzip -c #{@@vibDirs["tmp"]}/oem.tgz > #{@@vibDirs["tmp"]}/oem.tar",false,true)
      exec_local("cd #{@@vibDirs["oem"]} && tar -xvf #{@@vibDirs["tmp"]}/oem.tar",false,true)
    elsif @@vibOptions["input_type"] == 1
      print_out("Setting OEM dir to #{@@vibOptions["input_dir"]}")
      @@vibDirs["oem"] == @@vibOptions["input_dir"]
    end
    print_out("Creating OEM file List")
    fList = exec_local("cd #{@@vibDirs["oem"]} && find * -type f",true,true)
    @@vibData["files"] = fList.split("\n")
    fHandle = File.open("#{@@vibDirs["tmp"]}/oemfiles.lst","w")
    @@vibData["files"].each do |f|
      fHandle.write("#{f}\n")
    end
    fHandle.close()
  end

  def mktempdir()
    dirNList = @@vibDirs.keys
    dirNList.reverse!
    dirNList.each do |n|
      if Dir.exist?(@@vibDirs[n])
        print_out("Deleting Dir: #{@@vibDirs[n]}")
        FileUtils.rm_rf(@@vibDirs[n])
      end
    end
    @@vibDirs.each do |n,d|
      if !Dir.exist?(d)
        print_out("Creating Dir: #{d}")
        Dir.mkdir(d)
      end
    end
  end
end
