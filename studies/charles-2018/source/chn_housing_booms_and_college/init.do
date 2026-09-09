
program drop _all
program define post_param, eclass
  ereturn scalar `1' = `2'
end
