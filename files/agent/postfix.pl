#! /usr/bin/perl
#
# Sensor for gathering Postfix performance data for Zabbix
# Copyright (c) 2009 Hrvoje Sute
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Changes and Modifications
# * Fri May  1 21:15:15 CEST 2009
#       - rewritten from sh to perl

use strict;
use warnings;

# zabbix path
chomp(my $zabbix_sender=`which zabbix_sender 2>/dev/null`);
#my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/zabbixSenderFilePostfix";
my $zabbix_send_command="$zabbix_sender -c $zabbix_confd -i $send_file";
my $inputString = '';
my $hostname = `/bin/hostname -f`;
chomp($hostname);

# signal handling
$SIG{'ALRM'} = sub {
        local $SIG{TERM} = 'IGNORE';
        kill TERM => -$$;
        print "0\n";
};

local $SIG{TERM} = sub {
        local $SIG{TERM} = 'IGNORE';
        kill TERM => -$$;
        print "0\n";
};

alarm 25;

# function to add zeros
sub append0 {
  my $tmp=shift;
  $tmp =~ s/\.//;
  $tmp =~ s/K/0/i;
  $tmp =~ s/M/0000/i;
  $tmp =~ s/G/0000000/i;
  $tmp =~ s/T/0000000000/i;
  $tmp;
}

# postfix access data
my $postfixlog="/var/log/mail.log";
my $postfixstate="/tmp/zabbix-postfix-offset";
my $logtail="/usr/sbin/logtail";
#chomp(my $logtail=`which logtail 2>/dev/null`);
my $pflogsumm="/usr/sbin/pflogsumm";
#chomp(my $pflogsumm=`which pflogsumm 2>/dev/null`;)

# generate command
my $report_cmd = "$logtail -f$postfixlog -o$postfixstate | $pflogsumm -h 0 -u 0 --ignore-case --no_no_msg_size --detail=0";
my $output = qx($report_cmd);
#print $output;

# get data
my %data;
$data{'postfix.received'} = $1 if ($output =~ / +(\d+) +received/) || 0;
$data{'postfix.delivered'} = $1 if ($output =~ / +(\d+) +delivered/) || 0;
$data{'postfix.forwarded'} = $1 if ($output =~ / +(\d+) +forwarded/) || 0;
$data{'postfix.deferred'} = $1 if ($output =~ / +(\d+) +deferred/) || 0;
$data{'postfix.bounced'} = $1 if ($output =~ / +(\d+) +bounced/) || 0;
$data{'postfix.rejected'} = $1 if ($output =~ / +(\d+) +rejected/) || 0;
$data{'postfix.rejectwarnings'} = $1 if ($output =~ / +(\d+) +reject warnings/) || 0;
$data{'postfix.held'} = $1 if ($output =~ / +(\d+) +held/) || 0;
$data{'postfix.discarded'} = $1 if ($output =~ / +(\d+) +discarded/) || 0;
$data{'postfix.bytesreceived'} = $1 if ($output =~ / +(\d+) +bytes received/) || 0;
$data{'postfix.bytesdelivered'} = $1 if ($output =~ / +(\d+) +bytes delivered/) || 0;

# find out length of mailque
my $mailq = qx("/usr/bin/mailq");
my $i=0; 
while($mailq =~ s/\n[0-9ABCDEF]+\*?(\s+)/$1/){
  $i++;
}
$data{'postfix.mailqueue'} = $i;

# write data to variable
foreach my $key (keys %data){
  $inputString .= $hostname ." ". $key ." ". $data{$key} ."\n" if($data{$key}) ne ''; 
}
#print $inputString;

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
