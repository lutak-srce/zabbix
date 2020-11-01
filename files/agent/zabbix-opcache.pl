#!/usr/bin/perl

use LWP::UserAgent;
use strict;

my $path = shift or die "Usage: $0 path mem/hit";
my $item = shift or die "Usage: $0 path mem/hit";
my $timeout = 10;
my $hostname = 'localhost';
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
my $ua = LWP::UserAgent->new(timeout=>$timeout);
my $res = $ua->get("$path");
if (!$res->is_success) {
    die("Retrieving data failed: ".$res->status_line);
}

my @values = split('\n', $res->content);
if("$item" eq "mem"){
  my @moj = split(' ', $values[1]);
  my $out = $moj[1]/(1000 * 1000);
  print("$out");
}elsif("$item" eq "hit"){
  my @moj = split(' ', $values[0]);
  print("$moj[1]");
}
