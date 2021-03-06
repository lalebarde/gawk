@load "fork"

BEGIN {
   fn = ("fork.tmp." PROCINFO["pid"])
   switch (pid = fork()) {
   case -1:
      printf "Error: fork failed with ERRNO %s\n", ERRNO
      exit 1
   case 0:
      # child
      printf "pid %s ppid %s\n", PROCINFO["pid"], PROCINFO["ppid"] > fn
      exit 0
   default:
      # parent
      erc = 1
      if ((rc = wait()) < 0)
	 printf "Error: wait failed with ERRNO %s\n", ERRNO
      else if (rc != pid)
	 printf "Error: wait returned %s instead of child pid %s\n", rc, pid
      else if ((getline x < fn) != 1)
	 printf "Error: getline failed on temp file %s\n", fn
      else {
	 expected = ("pid " pid " ppid " PROCINFO["pid"])
	 if (x != expected)
	    printf "Error: child data (%s) != expected (%s)\n", x, expected
	 else if ((rc = system("rm  " fn)) != 0)
	    printf "Error removing temp file %s with ERRNO %s\n", fn, ERRNO
	 else
	    erc = 0
      }
      exit erc
   }
}
