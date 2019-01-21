# DHCP Server Scanner (d1s2)
# Written by Eric McCullough
# 

use strict;
use JSON;
use Getopt::Long;
use LWP::UserAgent;
use c3p0; # shared subroutines

my $user = "mcculloughs/eric mccullough%p1izzaR2d2!"; # use kerberos?
my ($year, $mon, $mday, $hour, $min);

my @dhcpservers = get_dhcp_servers(); # ('192.168.100.66',); # get from server?
#print "server = $dhcpservers[0]{'ip'}\n";

my %host_list;
my %ip_list;
my %mac_list;
my %reserved_ips;

my $showhelp;
my $result = GetOptions(
  "help|?" => \$showhelp,
  );

if ($showhelp) {
  &showhelp;
}

($year, $mon, $mday, $hour, $min) = gettime();
&printandpush("Looking for possible rogue hosts at $hour:$min of $mon/$mday/$year\n\n");
my $totalcount = my $foundcount = 0; # for counts of total hosts in dhcp, count of found possible rogue hosts.
my $total_scopes = 0;

foreach my $server_hash (@dhcpservers) {
  my $server = $$server_hash{'ip'};
  my @saved_scopes = get_scopes($$server_hash{'id'}); # from the API
  my %scopes;
  $scopes{'server'}{'id'} = $$server_hash{'id'};
  $scopes{'server'}{'scopes_attributes'} = [];
  # get dhcp scopes with description and comments.  Also get reserved IPs and default gateways for each scope.
  my $SCOPES;
  open($SCOPES, "/home/pi/winexe-1.00/source4/bin/winexe -U \"$user\" //$server 'netsh dhcp server \\\\$server dump'|") or warn "Can't get scopes and reserved IPs: $!\n";
  print STDERR "\nLoading scopes and reserved IPs from server at $server\n";
  my $scope_count = 0;
  my $lease_time = my $scope_state = 0;
  my ($scope, $ip, $mask, $desc, $comment);

  while (<$SCOPES>) { # load DHCP scopes
    if (/ERROR: Failed to open connection - NT_STATUS_LOGON_FAILURE/) {
      print STDERR "ERROR: Failed to open connection - NT_STATUS_LOGON_FAILURE\n";
      next;
    }
    if (/add scope/) {
      if (defined $ip) {
        my $found;
        foreach my $ss_array ($saved_scopes[0]) {
          foreach my $ss_hash (@$ss_array) {
            if ($$ss_hash{'ip'} eq $ip) { # scope exists in DB
              $found = 'Y';
              my $update;
              if ($mask ne $$ss_hash{'mask'}) { $update = 'Y';
              } elsif ($desc ne $$ss_hash{'description'}) { $update = 'Y';
              } elsif ($comment ne $$ss_hash{'comment'}) { $update = 'Y';
              } elsif ($lease_time ne $$ss_hash{'leasetime'}) { $update = 'Y';
              } elsif ($scope_state ne $$ss_hash{'state'}) { $update = 'Y';
              }
              if ($update eq 'Y') {
                print STDERR "Scope $ip changed, updating.\n";
                $scope = { ip => $ip, mask => $mask, description => $desc, comment => $comment, leasetime => $lease_time, state => $scope_state };
                push $scopes{'server'}{'scopes_attributes'}, $scope;
                update_scope($$server_hash{'id'}, encode_json \%scopes);
                $scopes{'server'}{'scopes_attributes'} = [];
              }
              last;
            }
          }
        }
        if ($found ne 'Y') {
          print STDERR "create scope $ip\n";
          $scope = { ip => $ip, mask => $mask, description => $desc, comment => $comment, leasetime => $lease_time, state => $scope_state };
          push $scopes{'server'}{'scopes_attributes'}, $scope;
          update_scope($$server_hash{'id'}, encode_json \%scopes);
          $scopes{'server'}{'scopes_attributes'} = [];
        }
      }
      $lease_time = $scope_state = 0;
      ($ip, $mask, $desc, $comment) = /.+scope ([\d\.]+) ([\d\.]+).+"(.*)" "(.*)"/;
    } elsif (/set state (\d)/) {
      $scope_state = $1;
      if ($scope_state eq '1') { # 1 == active scope
        $scope_count += 1;
      } else { print STDERR "Skipping inactive scope $ip\t$desc\t$comment\n"; }
    } elsif ($scope_state eq '1') {
      #Dhcp Server 14.15.19.14 Scope 14.15.42.0 Add reservedip 14.15.42.101 001577a08c0c "WD0800493.odd.com" "for firewall rules" "BOTH"
      if (/Add reservedip ([\d\.]+) ([\w]+) "(.*)"/) {
        my $ip = $1;
        my $mac = uc($2);
        $mac =~ /([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})/;
        $reserved_ips{$ip} = "$1-$2-$3-$4-$5-$6";
      } elsif (/optionvalue 3 IPADDRESS "([\d\.]+)"/) {
        $reserved_ips{$1} = "Default Gateway";
      } elsif (/optionvalue 51 DWORD "(\d+)"/) { # lease duration in seconds
        $lease_time = $1;
      }
    }
  }
  if (defined $ip) {
    my $found;
    foreach my $ss_array ($saved_scopes[0]) {
      foreach my $ss_hash (@$ss_array) {
        if ($$ss_hash{'ip'} eq $ip) { # scope exists in DB
          $found = 'Y';
          my $update;
          if ($mask ne $$ss_hash{'mask'}) { $update = 'Y';
          } elsif ($desc ne $$ss_hash{'description'}) { $update = 'Y';
          } elsif ($comment ne $$ss_hash{'comment'}) { $update = 'Y';
          } elsif ($lease_time ne $$ss_hash{'leasetime'}) { $update = 'Y';
          } elsif ($scope_state ne $$ss_hash{'state'}) { $update = 'Y';
          }
          if ($update eq 'Y') {
            print STDERR "Scope $ip changed, updating.\n";
            $scope = { ip => $ip, mask => $mask, description => $desc, comment => $comment, leasetime => $lease_time, state => $scope_state };
            push $scopes{'server'}{'scopes_attributes'}, $scope;
            update_scope($$server_hash{'id'}, encode_json \%scopes);
            $scopes{'server'}{'scopes_attributes'} = [];
          }
          last;
        }
      }
    }
    if ($found ne 'Y') {
      print STDERR "create scope $ip\n";
      $scope = { ip => $ip, mask => $mask, description => $desc, comment => $comment, leasetime => $lease_time, state => $scope_state };
      push $scopes{'server'}{'scopes_attributes'}, $scope;
      update_scope($$server_hash{'id'}, encode_json \%scopes);
      $scopes{'server'}{'scopes_attributes'} = [];
    }
  }
  print STDERR "Number of active scopes loaded from $server is $scope_count\n\n";
  $total_scopes += $scope_count;
  close $SCOPES;

  # make a flag to indicate we need to get the updated scope list
  @saved_scopes = get_scopes($$server_hash{'id'}); # get scope list including any updates made above.
  foreach my $ss_array ($saved_scopes[0]) {
    foreach my $scope (@$ss_array) {
      print STDERR "Searching $$scope{'ip'}...\n";
      my @saved_leases = get_leases($$scope{'id'}); # from the API
      my %leases;
      $leases{'scope'}{'id'} = $$scope{'id'};
      $leases{'scope'}{'leases_attributes'} = [];
    
      open (DHCPCMD, "/home/pi/winexe-1.00/source4/bin/winexe -U \"$user\" //$server 'netsh dhcp server \\\\$server scope $$scope{'ip'} show clients 1'|") or
        die "winexe //$server 'netsh dhcp server $server scope $$scope{'ip'} show clients 1' command failed";
      while (<DHCPCMD>) {
        my $lease = my $device = my $name = my $expiration = my $ip = my $dhcpmac = my $kind = my $mask = my $id = "";
        if (/The command needs a valid Scope IP Address/) {
          print STDERR "winexe -U $user //$server netsh failed to read scopes from $server, running under priviledged account?\n";
        } elsif (/^\d{1,3}/) {
          $totalcount += 1;
          # each record has the following format
          # IP Address      - Subnet Mask    - Unique ID           - Lease Expires        -Type -Name
          # 14.15.14.12  - 255.255.252.0  - 00-1a-4b-18-02-8a   -5/9/2010 9:20:44 AM    -D-  P-3D1053.com
          if ( ($ip, $mask, $dhcpmac, $expiration, $kind, $name)  # has normal lease date/time
              = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(.{17})\s*-\s*([0-9\/]+\s*[\d:]+\s*[AP]M)\s*-([DBURN])-\s*(.+)/ ) {
          } elsif ( ($ip, $mask, $dhcpmac, $expiration, $kind, $name) # has NEVER EXPIRES, INACTIVE, in lease field
              = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*- (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(.{17})\s*-\s*([\s\w]+)\s*-([DBURN])-\s*(.+)/ ) {
            while ($expiration =~ s/\s$//g) {}
          }
          if (defined $ip) {
            $dhcpmac = uc($dhcpmac); # upper case the letters in the MAC
            $dhcpmac =~ s/ //g; # remove spaces from the MAC
            $dhcpmac =~ s/-/:/g;
            $device = get_device($dhcpmac); # from the API
            
            $name =~ s/\.$//; # remove trailing '.' from host name
            $name =~ s/\s//g; # remove whitespace from host name
            $name = uc($name); # upper case the host name
            $name =~ /([\w\-\_]+)\.*/;
            
            $foundcount += 1;
            $host_list{$name} += 1;
            $ip_list{$ip} += 1;
            $mac_list{$dhcpmac} += 1;
            
            my $found;
            foreach my $sl_array ($saved_leases[0]) {
              foreach my $sl_hash (@$sl_array) {
                if ($ip eq $$sl_hash{'ip'}) {
                  $found = 'Y';
                  my $update;
                  if ($$sl_hash{'mask'} ne $mask) { $update = 'Y'; }
                  elsif ($$sl_hash{'name'} ne $name) { $update = 'Y'; }
                  elsif ($$sl_hash{'expiration'} ne $expiration) { $update = 'Y'; }
                  elsif ($$sl_hash{'kind'} ne $kind) { $update = 'Y'; }
                  elsif ($$sl_hash{'device_id'} ne $$device{'id'}) { $update = 'Y'; }
                  if ($update eq 'Y') {
                    print STDERR "lease $ip changed, updating.\n";
                    $lease = { id => $$sl_hash{'id'}, ip => $ip, mask => $mask, name => $name, expiration => $expiration, kind => $kind, device_id => $$device{'id'} };
                    push $leases{'scope'}{'leases_attributes'}, $lease;
                    update_lease($$scope{'id'}, encode_json \%leases);
                    $leases{'scope'}{'leases_attributes'} = [];
                  }
                  last;
                }
              }
              last if $found eq 'Y';
            }
            if ($found ne 'Y') {
              print STDERR "Create lease $ip\n";
              $lease = { ip => $ip, mask => $mask, name => $name, expiration => $expiration, kind => $kind, device_id => $$device{'id'} };
              push $leases{'scope'}{'leases_attributes'}, $lease;
              update_lease($$scope{'id'}, encode_json \%leases);
              $leases{'scope'}{'leases_attributes'} = [];
            }
          }
        }
      }
    }
  }
}

my $count = @dhcpservers;
print STDERR "Found $foundcount host(s) out of a total of $totalcount listed in the $total_scopes DHCP scopes on $count server(s).\n";

print STDERR "\n";
foreach my $host (keys %host_list) {
  if ($host_list{$host} > 1) { print STDERR "\"$host\" is a duplicate host name which occurs $host_list{$host} times\n"; }
}

print STDERR "\n";
foreach my $ip (keys %ip_list) {
  print STDERR "$ip is a duplicate ip address\n" if $ip_list{$ip} > 1;
}

print STDERR "\n";
foreach my $mac (keys %mac_list) {
  print STDERR "$mac is a duplicate MAC address\n" if $mac_list{$mac} > 1;
}

($year, $mon, $mday, $hour, $min) = gettime();
print STDERR "Completed at $hour:$min of $mon/$mday/$year\n";

##########################
# Subroutines
##########################

sub showhelp {
  print STDERR <<THERE ;

           DHCP Server Scanner
Reads DHCP server to feed the Remote Rogue Device Detector.

To run without options, from a command prompt enter:
d1s2.pl

Options:
  --help     print this help and exit

THERE
  exit;
}

sub get_dhcp_servers {
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/servers";
  my $req = HTTP::Request->new(GET => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      #print "get_dhcp_servers received reply: $message\n";
  } else {
      print "HTTP GET error code: ", $resp->code, "\n";
      print "HTTP GET error message: ", $resp->message, "\n";
  }
  my @array = decode_json($resp->decoded_content);
  return $array[0][0];
}

sub get_scopes {
  my $server_id = shift;
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/servers/$server_id/scopes";
  my $req = HTTP::Request->new(GET => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      #print "get scopes received reply: $message\n";
  } else {
      print "HTTP GET scopes error code: ", $resp->code, "\n";
      print "HTTP GET scopes error message: ", $resp->message, "\n";
  }
  my @array = decode_json($resp->decoded_content);
  return $array[0];
}

sub update_scope {
  my $server_id = shift;
  my $json = shift;
  #{"server"=>{"scopes_attributes"=>[{"leasetime"=>"691200", "ip"=>"1.1.1.0", "comment"=>"The Comment", "description"=>"The Description", "state"=>"1", "mask"=>"255.255.255.0"}]}, "subdomain"=>"api", "controller"=>"api/servers", "action"=>"update", "id"=>"1"}
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/servers/$server_id";
  my $req = HTTP::Request->new(PUT => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  
  $req->content($json);
  
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      #print "update scope received reply: $message\n";
  } else {
      print "HTTP PUT scope error code: ", $resp->code, "\n";
      print "HTTP PUT scope error message: ", $resp->message, "\n";
  }
}

sub get_device { # find or create device
  my $mac = shift;
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/devices/$mac";
  my $req = HTTP::Request->new(GET => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      #print "get device received reply: $message\n";
  } else {
      print "HTTP GET device error code: ", $resp->code, "\n";
      print "HTTP GET device error message: ", $resp->message, "\n";
  }
  my @array = decode_json($resp->decoded_content);
  return $array[0];
}

sub get_leases {
  my $scope_id = shift;
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/scopes/$scope_id/leases";
  my $req = HTTP::Request->new(GET => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      #print "get leases received reply: $message\n";
  } else {
      print "HTTP GET leases error code: ", $resp->code, "\n";
      print "HTTP GET leases error message: ", $resp->message, "\n";
  }
  my @array = decode_json($resp->decoded_content);
  return $array[0];
}

sub update_lease {
  my $lease_id = shift;
  my $json = shift;
  my $ua = LWP::UserAgent->new;
  my $server_endpoint = "http://api.r2d2.com:3000/api/scopes/$lease_id";
  my $req = HTTP::Request->new(PUT => $server_endpoint);
  $req->header('content-type' => 'application/json');
  $req->header('Accept' => 'application/json');
  
  $req->content($json);
  
  my $resp = $ua->request($req);
  if ($resp->is_success) {
      my $message = $resp->decoded_content;
      #print "update lease received reply: $message\n";
  } else {
      print "HTTP PUT lease error code: ", $resp->code, "\n";
      print "HTTP PUT lease error message: ", $resp->message, "\n";
  }  
}
