#!/usr/bin/perl
#
#       $Id: openvpnstatus.pl,v 1.1 2009/08/22 22:34:53 mattieu Exp $
#
# Copyright (c) 2009 Mattieu Baptiste <mattieu.b@free.fr>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


# This script parses one or more OpenVPN log files passed as command line
# arguments and generate HTML tables in conformance to these files.
# You must have HTML header and footer files in the directory of this
# script. Use like this :
#	openvpnstatus.pl file1.log [file2.log...] > log.html

use strict;
use warnings;

# VaRs
my $header = "/home/commun/scripts/header.inc.html";
my $footer = "/home/commun/scripts/footer.inc.html";
my $cntableheader = "<tr><td>Number</td><td>Common Name</td><td>Real Address</td><td>Bytes Received</td><td>Bytes Sent</td><td>Connected Since</td></tr>\n";
my $iptableheader = "<tr><td>Number</td><td>Virtual Address</td><td>Common Name</td><td>Real Address</td></tr>\n";

# Script body
cathtml($header);
foreach (@ARGV) {
	parsefile($_);
}
cathtml($footer);

# Script functions
sub cathtml {
	open FILE, $_[0] || die "Could not open file $_\n";
	while (<FILE>) {
		print;
	}
	close FILE;
}

sub parsefile {
	my @lines;
	my @data;
	my $line;
	my @allcndata;
	my @allipdata;

	open DATA, "< $_[0]" || die "Could not open file $_[0]\n";
	@lines = <DATA>;
	close DATA;

	foreach $line (@lines) {
		chomp $line;
		$line =~ s/^\s+//;
		if ($line =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)/) {
			@data = split(/,/, $line);
			unshift(@allipdata,"@data");
		}
		elsif ($line =~ /.(\w+?),(\d+)\.(\d+)\.(\d+)\.(\d+)/) {
			@data = split(/,/, $line);
			unshift(@allcndata,"@data");
		}   
		elsif ($line =~ /.(\w+?)-.(\w+?),(\d+)\.(\d+)\.(\d+)\.(\d+)/) {
			@data = split(/,/, $line);
			unshift(@allcndata,"@data");
		}
	}
	print "<h1>$_[0]</h1>\n";
	createtable(\@allcndata, $cntableheader, "cn");
	createtable(\@allipdata, $iptableheader, "ip");
}

sub createtable { 
	my $data;
	my $tableheader;
	my $type;
	my @element;
	my $count;

	($data, $tableheader, $type) = @_;
	print "\t<table border='1'>\n";
	print "\t$tableheader";
	$count = 1; 
	foreach (@$data) {
		@element = split ' ', $_;
		if ($type eq "cn") {
			print "\t\t<tr><td>";
			print "$count";
			print "</td><td>";
			print shift @element;
			print "</td><td>";
			print shift @element;
			print "</td><td>";
			print shift @element;
			print "</td><td>";
			print shift @element;
			print "</td><td>";
			print join ' ', @element;
			print "</tr>\n";
		}
		elsif ($type eq "ip") {
			print "\t\t<tr><td>";                                                                    
			print "$count";
			print "</td><td>";
			print shift @element;                                                       
			print "</td><td>";                                                  
			print shift @element;                                   
			print "</td><td>";                                
			print shift @element;
			print "</tr>\n";
		}
		$count++;
	}
	print "\t</table>\n\t<br />\n";
}
