def ver_str_valid(vers)
  prts = vers.split('.')  
  return [false] if prts.length < 1
  
  prts.each do |pt|
    return [false] if !/^[0-9]+$/.match(pt)
  end 

  prts << '0' until prts.length == 3

  return [true,prts]
end

def const_valid(v_const)
  valid_ops = ['=','>=', '<=', '<', '>', '~>' ]
  ### maybe a better way to do this - look for first digit, and split from there if needed.
  c_op, c_vers = v_const.split(' ')
  check = ver_str_valid(c_vers)
  if check[0] && valid_ops.include?(c_op)
    return [ true, c_op, check[1] ]
  else
    return [false]
  end
end

def pess_const(v_const)
  c_op, c_vers = v_const.split(' ')
  prts = c_vers.split('.')  

  return [ prts[0], (prts[1].to_i + 1).to_s ,'0'] if prts.length == 3
  return [ (prts[0].to_i + 1).to_s ,'0','0'] if prts.length == 2
end
  
 
def ver_satisfies?(c_op, c_vers, v_vers)
  satisfy = false
  case c_op
  when '='
    satisfy = true  if c_vers == v_vers
  when '>','<'
    (0..2).each do |x| 
      tst = v_vers[x] + c_op + c_vers[x]
      if eval(tst)
        satisfy = true
        break
      elsif v_vers[x] != c_vers[x]
        break
      end
    end
  when '<=','>='
    if c_vers == v_vers 
      satisfy = true
    else
      (0..2).each do |x| 
        tst = v_vers[x] + c_op + c_vers[x]
        if eval(tst) && v_vers[x] != c_vers[x]
          satisfy = true
          break
        elsif v_vers[x] != c_vers[x]
          break 
        end
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
  if c_check[1] == '~>'
    lwlimit = ver_satisfies?('>=', c_check[2], v_check[1]) 
    uplimit = ver_satisfies?('<',  pess_const(const), v_check[1])
    if lwlimit && uplimit
      return true
    else
      return false
    end 
  else 
    return ver_satisfies?(c_check[1], c_check[2], v_check[1])
  end
end
