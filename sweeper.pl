#! /usr/bin/perl
# Written by Eric McCullough
# TODO:
#   MAC OUI lookup
#   loop every x seconds/minutes/hours
#   ICMP ping option
#   track ack response?
#   syslog output

#  http://search.cpan.org/~gomor/Net-Libdnet-0.98/lib/Net/Libdnet.pm
#  https://metacpan.org/source/GOMOR/Net-Libdnet-0.98/lib/Net/Libdnet/Arp.pm

use strict;
use Net::CIDR::Set;
use Net::Ping;
use JSON;
use Net::Pcap;
use Net::Netmask; # for cidr
use IO::Interface::Simple; # for my_ip and netmask
use Net::Libdnet::Route;  # for gateway
use Net::Libdnet::Arp; # for reading arp table

use c3p0; # shared subroutines
my ($year, $mon, $mday, $hour, $min);
my ($my_ip, $my_mac, $network_ip, $ip, $mask, $cidr, $gateway, @ips, %arpt);

my $if = IO::Interface::Simple->new('eth0');
$my_ip = $if->address;
$mask = $if->netmask;
$my_mac = $if->hwaddr;
$cidr = Net::Netmask->new($if->address, $if->netmask);

my $route_table = Net::Libdnet::Route->new;
$gateway = $route_table->get('0.0.0.0');

my $set = Net::CIDR::Set->new("$cidr");
if ($gateway eq '') {
  $gateway = 'undefined';
}
# should we remove the gateway from the scan? or make it optional?

print STDERR "My IP is $my_ip\nThe mask is $mask\nThe netblock in CIDR notation is $cidr\nThe gateway is $gateway\n";
$set->remove("$my_ip/32");

my $iter = $set->iterate_addresses;
while ( my $ip = $iter->() ) {
  push @ips, $ip;
}

$ip = pop @ips;
print STDERR "Skipping $ip as the broadcast address\n";
$network_ip = shift @ips;
print STDERR "Skipping $network_ip as the network address\n";

($year, $mon, $mday, $hour, $min) = gettime();
print STDERR "Looking for possible rogue hosts at $hour:$min of $mon/$mday/$year\n\n";

my $p = Net::Ping->new("syn", 1); # the second parm is timeout in seconds
$p->{port_number} = 4445; # doesn't matter what port, we just want the ARP response.
foreach my $ip (@ips) {
  $p->ping($ip);
}

my $arp_table = Net::Libdnet::Arp->new;
$arp_table->loop(\&arp_print);
sub arp_print {
   my $e = shift;
   $arpt{$e->{arp_pa}} = $e->{arp_ha};
}

while (my ($host,$rtt,$ip) = $p->ack) {
  #print STDERR "HOST: $host [$ip] ACKed port $p->{port_number} in $rtt seconds.\n";
  if (defined $arpt{$ip}) {
    #$arpt{$ip} .= ',ack';
  } else {
    print STDERR "$ip acked but did not have an ARP entry!\n";
    #$arpt{$ip} = 'none,ack';
  }
}
$p->close();

my $json = '{"sweep":{"description":"' . "$cidr" . '","nodes_attributes":[';
$json .= '{"ip":"' . $my_ip . '","mac":"' . $my_mac . '"},'; # include us in the sweep.
foreach my $ip (keys(%arpt)) {
#  print STDOUT "{ ip: '$ip', mac: '$arpt{$ip}'}\n";
  $json .= '{"ip":"' . $ip . '","mac":"' . $arpt{$ip} . '"},';
}
chop $json; # remove trailing comma
$json .= "]}}";
update_db($json);

($year, $mon, $mday, $hour, $min) = gettime();
print STDERR "Completed scan at $hour:$min of $mon/$mday/$year\n\n";

sub update_db {
  use LWP::UserAgent;
  my $json = shift;
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/sweeps";
  #my $server_endpoint = "https://api.strong-stone-3754.herokuapp.com/sweeps"; # does this work?

  # set custom HTTP request header fields
  my $req = HTTP::Request->new(POST => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  
  # add POST data to HTTP request body
  my $post_data = $json;
  $req->content($post_data);
  
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      print "Received reply: $message\n";
  } else {
      print "HTTP POST error code: ", $resp->code, "\n";
      print "HTTP POST error message: ", $resp->message, "\n";
  }
}
