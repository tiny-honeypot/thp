sub shell {
  $thpath = "$homedir";
  if ($thpath =~ m/^.*\/([^\/]+)/){
      $pathsuffix = $1;
  }
  if ($hostname =~ m/^([^\.]+)\./){
      $shortname = $1;
  }
  $prompt = "[root\@${shortname} ${pathsuffix}]# ";
  open(GREETING, "$greetbin|");
  while(<GREETING>) {
    print STDERR $_;
  }
  close(GREETING);

  print STDERR "$prompt";

  while (my $commandline = <STDIN>) {
  
    open(LOG, ">>$sesslog");
    select LOG;
    $|=1;
    print LOG $commandline;
    chomp $commandline;
    @commandline = (split ";", $commandline);

    while (@commandline){
        $commands = shift (@commandline) ;
    
        @command=split /\s+/,($commands);

        shift @command if ($command[0] =~ /^(\s|$)/);

        if ($command[0] =~ /\buname\b/){
            if ($command[1] =~ /-[amsv]\b/){
            print STDERR $shellhash{$command[0]}{$command[1]}, "\n";
            }else{
            print STDERR $shellhash{$command[0]}{-s}, "\n";
            }

        } elsif ($command[0] =~ /\bcd\b/){
            changedir("$command[1]");  

        } elsif ($command[0] =~ /\bpwd\b/){
            print STDERR "$thpath\n";

        } elsif ($command[0] =~ /\b(whoami|w|id|wget)\b/){
            print STDERR "$shellhash{$command[0]}\n";

        } elsif ($command[0] =~ /\b(exit|logout)\b/){
            close(LOG);
            return;

        }  
      }
	    print STDERR "$prompt";
    }
  }

  sub changedir{
      $elements = $_[0] or $elements = "$homedir";
      if ($elements =~ /^\/.*/){
          $elements =~ s/\///;
          @thpath = ();
      } else {
      @thpath = (split /\//, $thpath);
      }
      @elements = (split /\//, $elements);
      foreach $element (@elements){
          if ($element eq ".."){
             pop @thpath;
          } else {
             push @thpath, $element;
          }
      }
      $thpath = "/" . (join "/", @thpath);
      $thpath =~ s/^\/\//\//;
      $pathsuffix = pop @thpath;
      push @thpath, $pathsuffix;
      $pathsuffix = "/" unless $pathsuffix;
      $prompt = "[root\@$shortname $pathsuffix]# ";
  }
  sub hostname{
  }

%shellhash = (
	uname	=>	{
		-a	=>	"Linux localhost 2.2.17 #4 Mon Apr 7 09:04:33 EDT 2001 i686 unknown unknown GNU/Linux",
		-m 	=>	"i686",
		-s 	=>	"Linux",
		-v 	=>	"#4 Mon Apr 7 09:04:33 EDT 2001",
	},
	whoami	=>	"root",
	w	=>	  "3:32am  up  7:45, 10 users,  load average: 0.04, 0.05, 0.01
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU  WHAT",
	id	=>	"uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel)",
	wget	=>	"wget: missing URL
Usage: wget [OPTION]... [URL]...

Try `wget --help' for more options.",
);

