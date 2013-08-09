sub catchall {
  $ENV{'PATH'} = '/bin:/usr/bin';
  delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};

  open(GREETING, "$greetbin|");
  while(<GREETING>) {
    print STDERR $_;
  }
  close(GREETING);

  print STDERR "$prompt";

  while (<STDIN>) {
    open(LOG, ">>$sesslog");
    print STDERR "$prompt";
    print LOG $_;
    close(LOG);
    if (/exit|logout|quit/) {
	return;
    }
  }
}
