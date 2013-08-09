sub ftpport {

use IO::Socket;
my $portspec = shift;
my @portspec = split (/\,/, $portspec);

$rhost = "$portspec[0].$portspec[1].$portspec[2].$portspec[3]";
$rport = (($portspec[4] << 8) + $portspec[5]);

if (inet_aton($rhost) ne inet_aton($saddr)) {
	return "port502";
} else {
	return "port200";
}
}

sub active {

use IO::Socket;

%actvhash = (
	dir150	=>	"150 Opening ASCII mode data connection for directory listing.\x0d\x0a",
	retr150	=>	"150 Opening BINARY mode data connection for $arg.\x0d\x0a"
	stor150	=>	"150 Opening BINARY mode data connection for $arg.\x0d\x0a"
);

my $actvcmd = shift;
my $arg = shift;

my $sock = IO::Socket::INET -> new(PeerAddr => "$rhost",
				PeerPort => "$rport",
				Proto	 => "tcp"
)
   or return "actv425";

if ($actvcmd =~ /stor/i) {
	print STDERR $actvhash{stor150};
} elsif ($actvcmd =~ /retr/i) {	
	print STDERR $actvhash{retr150};
}

my ($upload, $booty);
return unless (defined ($upload = fork()));
if ($upload) {
	while ($booty = <$sock>) {
		print LOG $booty;
		LOG->autoflush(1);
	}
	kill ('TERM', $upload);
} else {
	while (<STDIN>) {
		print $sock $_;
	}
}

close $sock;
return "compl";
}
