#!/usr/bin/perl
#
# Sensor for gathering Apache performance data for Zabbix via
# apache mod_status.
# Copyright (c) 2009 Jakov Sosic
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
#
# Changes and Modifications
# * Wed Dec 30 00:18:43 CET 2009
# 	- fixed issues if mod_status gives partial information
# * Fri May  1 21:09:16 CEST 2009
# 	- rewritten sender to use only one connection
# 	- fixed alarms
# * Thu May 15 03:40:39 CEST 2008
#       - script created
#

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/zabbixSenderFileApache";
my $zabbix_send_command="$zabbix_sender -c $zabbix_confd -i $send_file";
my $inputString = '';
my $hostname = `/bin/hostname -f`;
chomp($hostname);

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

# fetch status from mod_status
my $cmd = '/usr/bin/curl -A "mozilla/4.0 (compatible; cURL 7.10.5-pre2; Linux 2.4.20)" -m 12 -s -L -k -b /tmp/bbapache_cookiejar.curl -c /tmp/bbapache_cookiejar.curl -H "Pragma: no-cache" -H "Cache-control: no-cache" -H "Connection: close" "http://localhost/server-status?auto"';
my $server_status = qx($cmd);
if (!( $server_status =~ /Uptime/ )) { print"0\n"; exit(-1); }

# get information from status output
my($total_accesses,$total_kbytes,$cpuload,$uptime, $reqpersec,$bytespersec,$bytesperreq,$busyservers, $idleservers, $scoreboard);
$total_accesses = $1 if ($server_status =~ /Total\ Accesses:\ ([\d|\.]+)/ig)||0;
$total_kbytes = $1 if ($server_status =~ /Total\ kBytes:\ ([\d|\.]+)/gi);
$cpuload = $1 if ($server_status =~ /CPULoad:\ ([\d|\.]+)/gi);
$uptime = $1 if ($server_status =~ /Uptime:\ ([\d|\.]+)/gi);
$reqpersec = $1 if ($server_status =~ /ReqPerSec:\ ([\d|\.]+)/gi);
$bytespersec = $1 if ($server_status =~ /BytesPerSec:\ ([\d|\.]+)/gi);
$bytesperreq = $1 if ($server_status =~ /BytesPerReq:\ ([\d|\.]+)/gi);
$busyservers = $1 if ($server_status =~ /BusyWorkers:\ ([\d|\.]+)/gi);
$idleservers = $1 if ($server_status =~ /IdleWorkers:\ ([\d|\.]+)/gi);
$scoreboard = $1 if ($server_status =~ /Scoreboard:\ ([A-Z_]+)/gi);

# write data to variable
$inputString .= $hostname ." apache.total_accesses ". $total_accesses ."\n" if ($total_accesses);
$inputString .= $hostname ." apache.total_kbytes "  . $total_kbytes   ."\n" if ($total_kbytes);
$inputString .= $hostname ." apache.cpuload "       . $cpuload        ."\n" if ($cpuload);
$inputString .= $hostname ." apache.uptime "        . $uptime         ."\n" if ($uptime);
$inputString .= $hostname ." apache.reqpersec "     . $reqpersec      ."\n" if ($reqpersec);
$inputString .= $hostname ." apache.bytespersec "   . $bytespersec    ."\n" if ($bytespersec);
$inputString .= $hostname ." apache.bytesperreq "   . $bytesperreq    ."\n" if ($bytesperreq);
$inputString .= $hostname ." apache.busyservers "   . $busyservers    ."\n" if ($busyservers);
$inputString .= $hostname ." apache.idleservers "   . $idleservers    ."\n" if ($idleservers);
#$inputString .= $hostname ." apache.scoreboard "    . $scoreboard     ."\n" if ($scoreboard);

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
