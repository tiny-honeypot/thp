thp
===

Tiny Honeypot

Created a Github Repo for archival purposes for tiny honeypot.

I accessed the files from the wayback machine. You can take a look at the page here: http://web.archive.org/web/20090827091208/http://www.alpinista.org/thp/

Be warned this a really old project but I felt this would be a good project to resurrect.

Quote/Description from page:
Tiny Honeypot - resource consumption for the good guys

They've been filling our logs, wires, and storage for years; now it's time to turn the tables around.
Wouldn't it be nice if every single unsolicited connection attempt tied up the attacker who launched it by appearing to actually work, all the while providing a little insight into their motives & intents? thp appears to listen on all ports otherwise not in legitimate use, providing a series of phony responses to attacker commands. Some are very simple, others are somewhat more interactive. The goal isn't to fool a skilled, determined attacker...merely to cloud the playing field with tens of thousands of fake services, all without causing unreasonable stress on the thp host.

As an addition to your state and content-aware Intrusion Detection System, ie: Snort, thp allows nearly every connection attempt to complete, thus your content rules have a chance to actually fire, rather than depending on simple port and protocol "context" filters.

The wonderfully robust & flexible Linux netfilter is used with the REDIRECT target used to send any incoming connection requests to the thp listener(s), which are managed by xinetd. This does limit the hosts that can play to Linux v2.4.x systems, but stateful firewalling that can do "many -> one" destination network address translation is essential. This concept could be extended to other platforms/firewalls with similar capabilities; I know of one such OpenBSD/ipf box...Dan, can I include your scripts?

IMPORTANT NOTE: You can certainly run this on hosts that are in daily use with a negligible impact on performance, but please be sure to customize the firewall script to suit your environment. If you aren't careful, any existing firewall configuration could be replaced by thp's default rules.
The latest version is 0.4.6.
