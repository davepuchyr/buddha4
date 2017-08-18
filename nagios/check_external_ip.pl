#!/usr/bin/perl -w

use strict;
use lib '/usr/lib64/nagios/plugins';
use utils qw( $TIMEOUT %ERRORS );
use LWP::UserAgent;

do { print "$0: missing host (ARGV[0])\n"; exit $ERRORS{'CRITICAL'}; } if ( scalar( @ARGV ) != 1 );

my $host = $ARGV[0];
$host .= ".avaritia.com" if ( index( $host, 'avaritia.com' ) == -1 );

my $recipients = join( ' ', ( 'dave_puchyr@yahoo.com', 'dave.puchyr@gmail.com' ) );
my $url = 'http://ipv4.myexternalip.com/raw';
my $request = HTTP::Request->new( 'GET', $url );
my $ua = LWP::UserAgent->new();
$ua->timeout( $TIMEOUT );
my $response = $ua->request( $request );
my $code = $response->code();

do { print "http response code = $code\n"; exit $ERRORS{'CRITICAL'}; } if ( $code != 200 );

my $content = $response->content();
my $reip = '(\d+\.\d+\.\d+\.\d+)';
my ( $ip ) = $content =~ m|$reip|;

my $dnsip = `host $host 8.8.8.8`;
( $dnsip ) = $dnsip =~ m|has address $reip|;

print "ip=$ip dnsip=$dnsip\n";

exit $ERRORS{'OK'} if ( $ip eq $dnsip );

my $iproute = `ip route`;
my $ifconfig = `ifconfig`;
my $df = `df -h`;
my $arp = `arp -a`;
my $top = `top -b -n 1 -c`;
`cat <<EOMAIL | mail -s '$host ip address mismatch: $ip != $dnsip' $recipients 
IP address reported by curl: $ip
 IP address reported by DNS: $dnsip

$iproute

$ifconfig

$df

$arp

$top
EOMAIL`;

exit $ERRORS{'WARNING'};


