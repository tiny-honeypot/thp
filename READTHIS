thp - the tiny honeypot

# version 0.4.6
# Copyright George Bakos - alpinista@bigfoot.com
# May 2003
# This is free software, released under the tems of the GNU General 
# Public License avaiable at http://www.gnu.org


INTRODUCTION
------------
I threw this together and started capturing pretty good poop, so a few
friends thought I should make it available.  Here it is. If you think
it's lame, that's fine.  I wasn't going to put it out, anyway.  You may find
it worthwile if you have only one ip address, and don't want to DNAT
everything incoming to an internal dedicated honeypot. I run it on several
machines that are in regular daily use.


DISCLAIMER
----------
This is a neat toy.  That's all it is.  You can learn from your toys
if you use them responsibly, or you can leave them lying around on 
the floor, trip on them, and break your neck. Don't come crying to me
because you thought my toys didn't break.  That's stupid. When it breaks,
grab a little glue and fix it, or throw it away; I don't care.
Have fun, learn something, help others learn, but don't whine because
you were told that this was foolproof.  It isn't.  Fools will always
provide the proof.


CONCEPT
-------
The concept is simple:  listen and record.  The only problem is that the
badguys can't speak until after a connection comes up.  So we give them one.
On any port they want.  Period. Upon connecting, they are presented with a
greeting (I use fortune) and a root prompt.  W00p! They are leet. If you 
prefer a silent listener (no greeting or prompt), that's cool, too. See the
section xinetd.d/inetd, below. Script kiddeez are your best entertainment value!

xinetd is used to open a single port.  New connections to it get handed off
to a simple Perl script that builds two files: a running connection tracker,
and a unique session file, into which we merely capture all data. That's also
where the root prompt comes from. Keystrokes, autorooter scripts, exploit
reconnects, whatever. (If you want other services emulated, you add another
xinetd.d file & change the commandline param & port)

iptables REDIRECT is used to pass all incoming connection requests, regardless
of destination port, to that xinetd listener, unless we make an exception.
Portmap is one such exception.

In order for the intruder-to-be to know what port rpc.cmsd (or any other rpc 
service) is listening on, she needs to ask the target system's portmapper.
So we fire up a portmapper, and feed it bogus mappings for every service we 
can.  Sort of like building a static arp table, only more funnerer.

Now, all of this port redirect tomfoolery is TCP only, but that's ok.  UDP 
is connectionless; once the attacker believes she knows what port to use,
off it flies.  And we capture it, even if there is no service at the near 
end. I personally use Snort & SHADOW to alert me & capture everything, you
go ahead and roll your own solution.  Mine accommodates a pretty busy DSL 
that serves my family, while still grabbing every bit of nastiness that is 
sent to it. There are also several large sites running this on much busier
production systems/networks with no noticeable impact on performance.

INSTALLATION
------------
I'm going to assume that you have a fully functioning IDS of some sort
up and running.  If not, you probably should put down the keyboard and
step away from the computer. Do not pass go, do not install this hpot.

.......... OK, now that they are out of the room, let's party. 

Keep your IDS sigs up to date, folks.  I use Snort for grabbing full binaries 
of anything that fires a sig, as well as SHADOW to have a complete header log.  
With SHADOW, I get logging even if I get hit with an 0-day that Snort misses. 
It's nice to be able to replay the progression of events, too. (plug, plug, 
plug)

I highly asvise you read through this file,as well as all of the comments in the
thp.conf and iptables.rules files, but if you don't care about the details, and 
just want to put this thing up as quickly as possible, here's the straight poop:

cd /usr/local
zcat <tgz file> | tar -xvf -
ln -s thp-0.x.x thp
mkdir /var/log/hpot
chown nobody:nobody /var/log/hpot
chmod 700 /var/log/hpot
cp ./thp/xinetd.d/* /etc/xinetd.d
edit xinetd files to change to :"disable = no"
make any path & preferences adjustements in thp.conf & iptables.rules
./thp/iptables.rules
/etc/rc.d/init.d/portmap start
pmap_set < ./thp/fakerpc
/etc/rc.d/init.d/xinetd start
come back here and read.

thp.conf
--------
You may want to read through this file & make some adjustments, although for
most folks, this will fly fine just as it is.  Read the comments & go. 
One new feature for 0.4.4 you MAY wish to turn on is "logtype". From thp.conf:
# Log format - "single" or "multi".  Single line format is easier to parse, but
# does not make any entry into the capture log until the session is complete.
# Multiline gives you separate "start" & "end" lines, but is a pain in the 
# toches to do anything with.
This means that if an intruder is actively in the pot, you WON'T see a log
entry. Sure, you'll still see it in netstat, iptables, xinetd, sid logs, etc., 
but thp won't summarize it in the captures log until the session ends. If you
depend on tailing the captures log for some kind of alert, it might be a good
idea to leave the logtype as "multi".

In thp.conf, there are a number of paths specified. If you don't like them, 
change them. You will need to create a log location. The default is 
/var/log/hpot. Go ahead and mkdir, chown nobody & chmod 700 it. 

logthis
-------
The file "logthis" is the main script of the lot.  It will create the master
log entries in /var/log/hpot/captures, and call the necessary input handler(s)
from thpfunc.pl.

thpfunc.pl
----------
This is most of the meat & potato(e?)s. If you want to extend thp's 
functionality, please put your handler in here & call it from logthis based on 
xinetd server_args. I am beginning to think this would be better as individual
files, rather than one big kahuna. I can't make major changes like that without 
pissing some folks off, so let's be democratic about it. All in favor, say aye.
The ayes have it. Expect individual files on your local supermarket shelves 
soon.

A couple of notes on SIDs:  
-------------------------
The session IDs (session filenames, as well) are derived from the start time of
the intruder's data, not his connection.  There may be a gap of a second or more
if the attack is not automated. Please remember this when correlating firewall
& IDS logs against SID files.
New for v0.4.2 is a better sub gettime() in thpfunc.pl.  There are two methods
of creating SIDs, depending on how cool your Perl is. If your Perl has 
syscall.ph built, then you will have microsecond-unique SIDs. If not, then
thp falls back on the old method of one SID per second.
The old method can, and will, result in multiple sessions logging to the same
file, if they both initiate within a second of each other. If you don't want
this, and your Perl isn't quite l33t 3NuF, take a look at h2ph(1) and make it 
happen. Yes, I know there is a very nice CPAN module available, but more folks
have C headers already on their boxes. To generate syscall.ph on my Linux:

# cd /usr/include
# h2ph * ./sys/* ./bits/*

xinetd/inetd
------------
Some inted type super-server needs to be installed. I prefer xinetd, but good 
ol' /sbin/inetd is ok, too; you'll just lose alot of flexibility, including the
ability to limit concurrent sessions.  Use the inetd.conf line here:

6635     stream  tcp     nowait  nobody    /usr/local/thp/logthis    logthis

From the xinted.d directory, copy the xinetd configure file "hpot" into your
system /etc/xinetd.d directory, and be sure to re-enable it by editing. Don't 
ask me why I used port 6635 for the catch-all, my head just happenned to fall on
those keys, then I woke up.

If you need it, xinetd is available from http://www.synack.net/xinetd/. Some 
folks will prefer a different listener; go for it.

If you are going to use any of the thpfunc.pl services (currently only ftp and a
really rudimentary http is in there), then the appropriate thp-<svc> file must 
also appear in the xinetd.d directory.  The only difference between these are 
the commandline param, serive name & port number.  The cmdline parameter tells 
the logthis script which subroutine to call from thpfunc.pl.

If you prefer any service to be a "silent listener", i.e. no response, no 
prompt, no nothin' except logging of input, comment out the "server_args" line 
in the appropriate xinetd.d file.

portmap
-------
I wanted to register every service imaginable with the portmapper, but didn't 
like the idea of actually running the daemons necessary and relying on the 
firewall to keep the beasties at bay (some dweeb's voice in my ear kept saying, 
"defense in depth.")  I was going to bang on the sources to portmapper and 
hardcode everything from /etc/rpc into there, but after I pulled the tarball 
down, I started reading and saw that pmap_dump and pmap_set would do it all.  
Cool.  Thanks Wietse.

The fakerpc here is derived from RedHat Linux 7.1, Irix 5.3, and Solaris 8's 
/etc/rpc files, and then built to include lines for versions 1-4 of each rpc 
program, via both udp and tcp. Start portmapper as normal, but instead of firing
up rpc programs, just execute:
		"pmap_set < /usr/local/thp/fakerpc".
There's a 1:1 chance that this will break your existing legit rpc services. If 
you are running rpc services on your firewall/hpot, you should go hang out with 
those non-IDS types above.

iptables
--------
I'll write this section later, or not.  For now, read the comments in the 
iptables.thp and edit as necessary, or incorporate the essential bits into your 
own ruleset. If you have an existing firewall script & aren't comfortable
modifying it yourself, feel free to ask.  I may have time to help.

I'm going to yell for a minute.  Stop reading if you are going to be offended.
WARNING! DANGER WILL ROBINSON! THIS WILL BREAK YOUR EXISTING IPTABLES FIREWALL.
Any questions? Read the disclaimer again.

Hey, Dan, when are you going to give us your /etc/pf.conf?

George
alpinista@bigfoot.com
