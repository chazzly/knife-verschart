def ver_str_valid(vers)
  prts = vers.split('.')  

  ### Validate
  if prts.length < 2
    print "Insufficient Version parts"
    return 1
  end
  
  #### Need a way to confirm they are all didgits - this didn't work
  prts.each do |pt|
    begin
      x = pt.to_i
    rescue
      print "Invalid ${pt} - Version Parts must numberic"
      return 2
    end
  end 

  if prts.length == 2
    prts << '0'
  end
  
  return prts
end

def const_valid(v_const)
  ### maybe a better way to do this - look for first digit, and split from there if needed.
  c_op, t_vers = v_const.split(' ')
  print c_op
  print t_vers
  c_vers = ver_str_check(t_vers)  
  print c_op
  print c_vers
end

def ver_satisfies?(c_op, c_vers, v_vers)
  satisfy = false
  (0..2).each do |x| 
    if c_op == "="
      if c_vers == v_vers
        satisfy = true
      end
    else
      tst = v_vers[x] + c_op + c_vers[x]
      if eval(tst)
        satisfy = true
        break
      elsif v_vers[x] == c_vers[x]
        satisfy = true
      else
        break
      end
    end
  end
  return satisfy
end 



     


