syntax match NtNow     "\v\[x\]"
syntax match NtSoon    "\v\[-\]"
syntax match NtLater   "\v\[ \]"

syntax match NtTag     "\v\+([^ ]*)"

syntax region NtBullet  "\v^\s*([^\[]*)"
