sub nullresp {
  while (<STDIN>) {
    open(LOG, ">>$sesslog");
    select LOG;
    $|=1;
    print LOG $_;
    close LOG;
  }
}
