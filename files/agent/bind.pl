#!/usr/bin/perl
#
# Sensor for gathering Bind performance data for Zabbix via
# rndc.stats command.
# Copyright (c) 2008 Jakov Sosic
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


# We use this script to produce graph with munin for dns requests
# This script must have his name start with bind_
# bind_ : Global bind statistic 
# bind_test.com : Bind statistic for test.com zone
#
# Magic markers
#%# family=auto
#%# capabilities=autoconf

use strict;

# signal handling
$SIG{'ALRM'} = sub {
	local $SIG{TERM} = 'IGNORE';
	kill TERM => -$$;
	print "0\n";
	exit(-1);
};

local $SIG{TERM} = sub {
	local $SIG{TERM} = 'IGNORE';
	kill TERM => -$$;
	print "0\n";
	exit(-1);
};

alarm 25;

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/zabbixSenderFileBindDNS";
my $zabbix_send_command="$zabbix_sender -c $zabbix_confd -i $send_file";
my $inputString = ''; 
my $hostname = `/bin/hostname -f`; 
chomp($hostname);

# change those to reflect your bind configuration
# stat file
my $stat_file = "/var/cache/bind/named.stats";
# rndc path
my $rndc = "/usr/sbin/rndc";
# sudo path
my $sudo = "/usr/bin/sudo";

# Remove old stat file
`$sudo /bin/rm -f $stat_file`;

# Ask to bind to build new one
`$sudo $rndc stats`;

open(IN,"<$stat_file");
my $server_status = do { local $/; <IN> };
close(IN);

# parse stat file
my( $success, $authoritative, $nauthoritative, $referral, $nxrrset, $failure, $nxdomain, $recursion );
$success	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ successful\ answer/ig)||0;
$authoritative	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ authoritative\ answer/ig)||0;
$nauthoritative	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ non\ authoritative\ answer/ig)||0;
$referral	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ referral\ answer/ig)||0;
$nxrrset	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ nxrrset/ig)||0;
$failure	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ SERVFAIL/ig)||0;
$nxdomain	= $1 if ($server_status =~ /([\d]+)\ queries\ resulted\ in\ NXDOMAIN/ig)||0;
$recursion	= $1 if ($server_status =~ /([\d]+)\ queries\ caused\ recursion/ig)||0;

# write data to variable
$inputString .= $hostname ." bind.success ". $success ."\n" if $success;
$inputString .= $hostname ." bind.authoritative ". $authoritative ."\n" if $authoritative;
$inputString .= $hostname ." bind.nauthoritative ". $nauthoritative ."\n" if $nauthoritative;
$inputString .= $hostname ." bind.referral ". $referral ."\n" if $referral;
$inputString .= $hostname ." bind.nxrrset ". $nxrrset ."\n" if $nxrrset;
$inputString .= $hostname ." bind.failure ". $failure ."\n" if $failure;
$inputString .= $hostname ." bind.nxdomain ". $nxdomain ."\n" if $nxdomain;
$inputString .= $hostname ." bind.recursion ". $recursion ."\n" if $recursion;

# write everything to file
open FH, ">", $send_file or die("Can not open file $send_file!");
print FH $inputString;
close(FH);

# finally, send the data
if ( qx($zabbix_send_command) =~ /Failed(:)? 0/i ) {
   unlink ($send_file) or die("Can not remove file $send_file!");
   print("1\n");
   exit(0);
} else {
   unlink ($send_file) or die("Can not remove file $send_file!");
   print("0\n");
   exit(-1);
}
#EOF
