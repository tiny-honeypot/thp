# /usr/local/thp/thpfunc.pl version 0.4.4

# Functions for use in thp 0.4.x  A component of the thp
# honeypot kit.
#
# Copyright George Bakos - alpinista@bigfoot.com
# July 15, 2002
# This is free software, released under the terms of the GNU General 
# Public License avaiable at http://www.fsf.org/licenses/gpl.txt


sub getip {
$reply = `/sbin/ifconfig $intf`;
if ($reply =~ /^.*?\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b.*/is) {
  $thpaddr = $1
}
}

# Since our SIDs are hex concatanations of unix time in seconds & microseconds,
# we need a way to pull hi-resolution timestamps. Otherwise, we settle for 
# one-second accuracy, possibly leading to some mangled session logging.
# If Time::HiRes is available, our lives are easy. If not, lets see if the
# necessary headers are available for a gettimeofday() syscall. If that
# bombs too, we're stuck with plain ol' time. :-p

sub gettime {
if ( eval "require Time::HiRes" ) { 
  import Time::HiRes ;
  my ($secs, $usecs) = Time::HiRes::gettimeofday();
  $timestp = sprintf ("%.X%.X", ("$secs", "$usecs"));
  $shorttime = $secs;
} elsif (eval "require 'sys/syscall.ph'") {
  my $now = pack("LL", ());
  syscall( &SYS_gettimeofday, $now, undef) >= 0
        or die "gettimeofday: $!";
  my($secs, $usecs) = unpack("LL", $now);
  $timestp = sprintf ("%.X%.X", ("$secs", "$usecs"));
  $shorttime = $secs;
} else {
$shorttime = $timestp = time();
}
}

# signal handlers

# Use a SIGALRM to limit time of execution of each script
# Since $sid is only used to label the caplog entry (once
# things get going) we can here add a comment to it and exit
# with a nonzero value.
# It's a bit of a kludge; please improve on this, folks.

sub closeout {
  $sid = "$sid - timeout";
  clcaplog();
  close(CAPLOG);
  exit 5;
}
$SIG{ALRM} = \&closeout;

# Here, we manage the caplog file, which tracks all sessions

sub opncaplog {
  gettime();
  $start = $shorttime;
  $sid = $timestp;

  if ($svcname) {
        $sid="$sid.$svcname"}

  $sesslog="$logdir/$sid";

  if ($logtype eq "single") {
  @capdata = ((strftime("%b %d %T", localtime(time))), ("SID=$sid"), ("PID=$procid"), ("SRC=$saddr"), ("SPT=$sport"));
  } else { print (CAPLOG "\n", strftime("%b %d %T", localtime(time)), " start thp SID $sid, UNIX pid $procid source $nsdata[4]\n");
  }
}


sub clcaplog {
  gettime();
  $end = $shorttime;
  $eltime = $end - $start;

  if ($logtype ne "single") {
    print CAPLOG strftime("%b %d %T", localtime(time)), " end thp SID $sid\n";
  }

  if ($eltime > 0) {
    $etstr = (strftime("%T", gmtime($eltime)));
    push (@capdata,("ET=$etstr"));
    if ($logtype ne "single") {
      print CAPLOG "\t- elapsed time ", $etstr, "\n";
    }
  }

  if ($size=(-s $sesslog)) {
    push (@capdata,("BYTES=$size"));
    if ($logtype ne "single") {
      print CAPLOG "\t- total $size bytes\n";
    }
  }
  if ($logtype eq "single") {
    print CAPLOG "@capdata\n";
  }
}
