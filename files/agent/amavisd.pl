#!/usr/bin/perl -w
#
# Sensor for gathering PosgreSQL performance data for Zabbix
# Copyright (c) 2008 Jakov Sosic
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
# * Mon Apr 27 19:00:56 CEST 2009
#       - fixed for PostgreSQL 8.3,
#         http://www.mail-archive.com/pgsql-hackers@postgresql.org/msg99007.html
#       - rewritten sender to use only one connection
# * Tue Mar 17 17:58:50 CET 2009
#       - fixed alarms
# * Thu May 15 03:40:39 CET 2008
#       - script created

use strict;
use warnings;
use DBI;

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/zabbixSenderFilePostgreSQL";
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

# amavis data
my $amavislog="/var/log/mail.log";
my $amavisstate="/tmp/zabbix-amavis-offset";
my $logtail="/usr/sbin/logtail";
my $cmd = "$logtail -f$amavislog -o$amavisstate";
#print $cmd;
#$cmd="cat /home/hsute/amavislog";
my $output = qx($cmd);

# get data
my %data;               #        print $output;
my @amavisLines = grep(! /TIMED OUT/, grep(/amavis\[\d*\]/, split("\n",$output)));
#my @tmpGrep = grep(/dovecot/, @tmpArr);
#$output = join("\n", @amavisLines); print $output;
my @tmpArr = grep(/CLEAN/, @amavisLines);
$data{'amavisd.clean'} = @tmpArr;
@tmpArr = grep(/INFECTED/, @amavisLines);
$data{'amavisd.virus'} = @tmpArr;
@tmpArr = grep(/Blocked SPAM/, @amavisLines);
$data{'amavisd.spam'} = @tmpArr;
$data{'amavisd.total'} = @amavisLines;
$data{'amavisd.other'} = $data{'amavisd.total'} - $data{'amavisd.clean'} - $data{'amavisd.virus'} - $data{'amavisd.spam'};

#####################################################################################################
$cmd="/usr/lib/zabbix-agent/check_amavis.pl";
alarm 5;
$output = qx($cmd);
$data{'amavisd.alivefunctional'} = chomp($output) if ($output);
#print "\n--$data{'dovecot.connectionsIMAPestablished'}!!";
######################################################################################################

# write data to variable
foreach my $key (keys %data){
  $inputString .= $hostname ." ". $key ." ". $data{$key} ."\n"; #$server ." ". $hostname ." ". $port
}

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
