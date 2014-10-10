def ver_str_valid(vers)
  prts = vers.split('.')  

  ### Validate
  if prts.length < 1
    print 'Insufficient Version parts'
    return false
  end
  
  #### Need a way to confirm they are all didgits - this didn't work
  prts.each do |pt|
    if !/^[0-9]+$/.match(pt)
      print "Invalid ${pt} - All version Parts must numberic"
      return false
    end
  end 

  until prts.length == 3
    prts << '0'
  end

  return [true,prts]
end

def const_valid(v_const)
  valid_ops = ['=','>=', '<=', '<', '>', '~>' ]
  ### maybe a better way to do this - look for first digit, and split from there if needed.
  c_op, c_vers = v_const.split(' ')
  #print c_op
  #print c_vers
  check = ver_str_valid(c_vers)
  if check[0] && valid_ops.include?(c_op)
    return [ true, c_op, check[1]]
  else
    return false
  end
end

def ver_satisfies?(c_op, c_vers, v_vers)
  satisfy = false
  case c_op
  when '='
    if c_vers == v_vers
      satisfy = true
    end
  when '~>'
  when '>','<'
    (0..2).each do |x| 
      tst = v_vers[x] + c_op + c_vers[x]
      if eval(tst)
        satisfy = true
        break
      end
    end
  end
  return satisfy
end 

def const_check(const, vers_to_check)
  c_check = const_valid(const)
  v_check = ver_str_valid(vers_to_check)
  if !c_check || !v_check
    return false
  end
  
  return ver_satisfies?(c_check[1], c_check[2], v_check[1])
end
