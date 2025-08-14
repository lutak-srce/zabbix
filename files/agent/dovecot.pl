#!/usr/bin/perl -w
#
# Sensor for gathering Dovecot performance data for Zabbix
# Copyright (c) 2008 Hrvoje Shute
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
# * Fri May  8 00:08:17 CEST 2009
#       - rewritten in perl
#       - rewritten sender to use only one connection

use strict;
use warnings;

# zabbix path
my $zabbix_sender="/usr/bin/zabbix_sender";
my $zabbix_confd="/etc/zabbix/zabbix_agentd.conf";
my $send_file="/var/tmp/zabbixSenderFileDovecot";
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

# dovecot data
my $logtail="/usr/sbin/logtail";
my $dovecotlog="/var/log/mail.log";
my $dovecotstate="/tmp/zabbix-dovecot-offset";
my $cmd = "$logtail -f$dovecotlog -o$dovecotstate";
my $output = qx($cmd);

# get data
my %data;               #        print $output;
my @dovecotLines = grep(/dovecot/, split("\n",$output));
#my @tmpGrep = grep(/dovecot/, @tmpArr);
#$output = join("\n", @dovecotLines); print $output;
my @tmpArrLogin = grep(/Login:/, @dovecotLines);
$data{'dovecot.loginstotalperDt'} = @tmpArrLogin;
my @tmpArr = grep(/TLS/, @tmpArrLogin);
$data{'dovecot.loginsTLSperDt'} = @tmpArr;
@tmpArr = grep(/secured/, @tmpArrLogin);
$data{'dovecot.loginsSSLperDt'} = @tmpArr;
@tmpArr = grep(/Aborted login:/, @dovecotLines);
$data{'dovecot.loginsabortedperDt'} = @tmpArr;
@tmpArr = grep(/imap-login:/, @dovecotLines);
$data{'dovecot.loginsIMAPperDt'} = @tmpArr;
@tmpArr = grep(/pop3-login:/, @dovecotLines);
$data{'dovecot.loginsPOP3perDt'} = @tmpArr;

$cmd="/bin/ps ax";
$output = qx($cmd);

my @psLines = split("\n",$output);
@tmpArr = grep(/imap-login/, @psLines);
$data{'dovecot.connectionsIMAPavailable'} = @tmpArr;
@tmpArr = grep(/imap/, grep(! /imap-login/, @psLines));
$data{'dovecot.connectionsIMAPestablished'} = @tmpArr;
@tmpArr = grep(/pop3-login/, @psLines);
$data{'dovecot.connectionsPOP3available'} = @tmpArr;
@tmpArr = grep(/pop3/, grep(! /pop3-login/, @psLines));
$data{'dovecot.connectionsPOP3established'} = @tmpArr;

#print "\n--$data{'dovecot.connectionsIMAPestablished'}!!";

#send file
foreach my $key (keys %data){
  $inputString .= $hostname ." ". $key ." ". $data{$key} ."\n" if($data{$key}); #$server ." ". $hostname ." ". $port
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
