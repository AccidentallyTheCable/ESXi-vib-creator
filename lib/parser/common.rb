def exec_local(command,return_data = false,print_data = true)
  begin
    if print_data == true && ($debug >= 4 || $verbose)
      print_out("Executing: #{command}")
    end
    returnData = %x(#{command})
    status = $?.exitstatus
    if status != 0
      raise "Command execution returned non-zero status"
    end
    if print_data == true
      print_out(returnData)
    end
    if return_data == true
      return returnData
    else
      return status
    end
  rescue StandardError, RuntimeError, ScriptError,SignalException => error
    print_out("SCRIPT HAS FAILED: #{error}")
    end_process 9000
  end
end


def print_out(string)
  time = Time.now
  curtime = time.strftime("%Y/%m/%d %H:%M:%S")
  if string.nil?
    string="Print was empty!?"
  end
  puts(string + "\n")
  unless $logHandle.nil?
    $logHandle.write("[#{curtime}] #{string}\n")
  end
end


def end_process(status)
  if status.nil?
    status = 0
  elsif !status.is_a?(Integer)
    status = 0
  end
  if status.nonzero?
    msgStatus = 'fail'
  else
    msgStatus = 'okay'
  end
  unless $logHandle.nil?
    $logHandle.close
    # %x(chmod 644 #{$logFile})
  end
  exit status
end

