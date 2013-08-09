# /usr/local/thp/lib/http.pl version 0.4.4
#
# httpd emultation functions for thp - Tiny Honeypot 
#
# Copyright George Bakos - alpinista@bigfoot.com
# Aud 02, 2002
# This is free software, released under the terms of the GNU General
# Public License avaiable at http://www.fsf.org/licenses/gpl.txt
#

sub http {

  while (my $commands = <STDIN>) {
    open(LOG, ">>$sesslog");
    select LOG;
    $|=1;
    print LOG $commands;
    $lcount++;
    $commands =~ s/\r//;
    my $commline = "line$lcount";
    @$commline = split /\s+/,($commands);

# Should we change labels? If selected in thp.conf, and the intruder is
# looking for common Microsoft-IIS resources, this will change the httpd 
# vendor & version to accomodate them.

    if ($line1[1] =~ /(pagerror.gif|\.asp|\.exe|\.htr|\.htx|\.htw|\.com\.dll|\.ida)[$\?%+]?/ && $chameleon eq "yes") {
      ($httpdvend, $httpdver) = ("Microsoft-IIS", "$chamelver");
    }
    $respdir = "$thpdir/lib/$httpdvend";

# Has the intruder specified an HTTP version in their request? If not,
# the session closes with an error - see err400()

    $method = $line1[0];
    $resname = $line1[1];
    $resname =~ s/^.*\///;
    $protover = "$line1[2]" if ($line1[2] =~ /HTTP\/1.[01]$/);
    
    if ($commands =~ /^$/m) {

# Check for an acceptable http method. If fatfingered or otherwise unknown,
# bomb out with an error 501. Not all daemons return 501s, some just spew
# error 400s for just about everything broken. I still need to ID where 
# this is appropriate.

        if ($method !~ /GET|POST|HEAD/ ) {
	  http_hdr("501","Bad Method","text/html");
	  err501();
	  exit 0;

# Is the URL too long? Feel free to monkey with this, or ditch it. This
# tests the entire URI, not just resource filename.

	} elsif ( length($line1[1]) > 255 ) {
	  http_hdr("414","Request-URI Too Large","text/html");
	  err414();
	  exit 0;

# Match on resource name. We allow "/" and "index.htm" and "index.html". All
# of these will return the content in lib/<vendor>/200. The return headers
# are built in http_hdr(), and content is pulled from the file. If your html
# document contains <img> tags, those image files should be placed in the same
# directory. We can't match on $resname here, since we stripped off all
# slashes, and would break default webpage requests. Thus it's back to 
# $line1[1].

	} elsif ( $line1[1] =~ m/^(\/$|\/index.htm[l]?)$/ && $protover) {
	  $respfile = "$respdir/200";
	  http_hdr("200","OK","text/html");
	  open (RESP, "$respfile");
	  while (<RESP>) {
	    chomp;
	    print STDERR ($_, "\x0d\x0a");
	  }
	  close RESP;
	  print STDERR ($_, "\x0d\x0a");
	exit 0;

# If the vendor is IIS and the request contains common default resource
# names, this returns the same lib/<vendor>/200

	} elsif ( $resname =~ /(default|iisstart|localstart)/ && $protover && $httpdvend eq "Microsoft-IIS") {
	  $respfile = "$respdir/200";
	  http_hdr("200","OK","text/html");
	  open (RESP, "$respfile");
	  while (<RESP>) {
	    chomp;
	    print STDERR ($_, "\x0d\x0a");
	  }
	  close RESP;
	  print STDERR ($_, "\x0d\x0a");
	exit 0;

# Here is the text catchall, setting a mimetype of /text/html. 

	} elsif ( -T "$respdir/$resname" && $protover) {
	  $respfile = "$respdir/$resname";
	  http_hdr("200","OK","text/html");
	  open (RESP, "$respfile");
	  while (<RESP>) {
	    print STDERR $_;
	  }
	  close RESP;
	  print STDERR "\x0d\x0a\x0d\x0a";
	exit 0;

# If the request is for an image, strip off the path and pull it out of 
# the same lib/<vendor>/ directory, modifying the mime type accordingly.

	} elsif ( $resname =~ /(gif|jpg|png)$/ && ($imgtype = "$+") && -f "$respdir/$resname" && $protover) {
	  $respfile = "$respdir/$resname";
	  http_hdr("200","OK","image/$imgtype");
	  open (RESP, "$respfile");
	  while (<RESP>) {
	    print STDERR $_;
	  }
	  close RESP;
	  print STDERR "\x0d\x0a\x0d\x0a";
	exit 0;

	} else { 
	  http_hdr("400","Bad Request","text/html");
	  err400() }
	exit 0;
    } 
    close LOG;
  }
}

sub http_hdr {
$fsize = -s $respfile;
$now = strftime("%a, %B %d %Y %T GMT", gmtime(time));
  print STDERR qq ($protover $_[0] $_[1]\x0d
Server: $httpdvend/$httpdver\x0d
Date: $now\x0d
Content-Length: $fsize\x0d
Connection: close\x0d
Content-Type: $_[2]\x0d\x0a);
if ( $_[2] =~ /image/ ) {
  print STDERR "Accept-Ranges: bytes\x0d\x0a";
}
if ( $httpdvend =~ /Microsoft/ ) {
  print STDERR "Set-Cookie: ASPSESSIONIDQQGGGHOO=GAFBCHFDEANKGFKPIPKENMAP; path=/\x0d\x0a";
  print STDERR "Cache-control: private\x0d\x0a";
}
print STDERR "\x0d\x0a";
}

sub err400 {
  my $msg = qq (<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>400 Bad Request</TITLE>
</HEAD><BODY>
<H1>Bad Request</H1>
Your browser sent a request that this server could not understand.<P>
Invalid URI in request "@line1"<P>
<HR>
<ADDRESS>$httpdvend/$httpdver Server at $thpaddr Port 80</ADDRESS>
</BODY></HTML>\x0d\x0a\x0d\x0a);
  print STDERR "$msg";
}

sub err414 {
  my $msg = qq (<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>414 Request-URI Too Large</TITLE>
</HEAD><BODY>
<H1>Request-URI Too Large</H1>
The requested URL's length exceeds the capacity
limit for this server.<P>
request failed: URI too long<P>
<HR>
<ADDRESS>$httpdvend/$httpdver Server at $thpaddr Port 80</ADDRESS>
</BODY></HTML>\x0d\x0a\x0d\x0a);
  print ( STDERR "$msg");
}

sub err501 {
  my $msg = qq (<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>501 Invalid Method</TITLE>
</HEAD><BODY>
<H1>Invalid Method</H1>
The requested method is not available on this server.<P>
request failed: Invalid or unrecognized method in "@line1"<P>
<HR>
<ADDRESS>$httpdvend/$httpdver Server at $thpaddr Port 80</ADDRESS>
</BODY></HTML>\x0d\x0a\x0d\x0a);
  print ( STDERR "$msg");
}

