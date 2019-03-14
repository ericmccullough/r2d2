# Remote Rogue Device Detector
# Written by Eric McCullough
#
use strict;
use Net::Ping;
use Getopt::Long;
use Win32::NetResource qw(:DEFAULT NetShareGetInfo GetError);
use c3p0; # shared subroutines

my @dhcpservers = (
  '13.15.19.14',
);

my %dcs = ( ### Domain-Controller-FQDN for use in dsquery ###
  'dc01'=>'DC=odd,DC=com',
  'dc10'=>'DC=odd,DC=com',
);

my $sleeptime = 0;
my ($verbose, $update, $listall, $showhelp); # commanline options
my ($totalcount, $foundcount, $blacklistcount); # for counts of total hosts in dhcp, count of found possible rogue hosts, and  count if found blacklisted devices.
my @notable;
my %foundb4;
my $ip;
my $dhcpmac;
my $alive;
my $vendor;
my $dhcphost;
my $lease;
my $scopedesc;
my %blacklist;
my %vendors;

my $result = GetOptions (
 	"sleep=i" => \$sleeptime,
  "verbose"  => \$verbose,
  "update" => \$update,
  "listall" => \$listall,
  "help|?" => \$showhelp,
);

if ($showhelp) {
  showhelp();
}

if ($update) {
  print STDERR "Updating vendor.txt file from the IEEE web site\n";
  updatevendorlist();
  exit;
}

if ($sleeptime > 86400) {
  print STDERR "Sleep option must be no more than 86400 (24 hours).\n";
  exit;
} else { printandpush("Sleep set to $sleeptime seconds\n"); }

foreach my $server (@dhcpservers) { # check that the server IP is a valid format
  my $ok = 0;
  unless ($server =~ /[^\d\.]/g) {
    if ($server =~ /(.+)\.(.+)\.(.+)\.(.+)/) {
      if ($1 >= 0 && $1 <= 255) {
        if ($2 >= 0 && $2 <= 255) {
          if ($3 >= 0 && $3 <= 255) {
            if ($4 >= 0 && $4 <= 255) {
              $ok = 1;
            }
          }
        }
      }
    }
  }
  if ($ok == 0 ) { printandpush("DHCP server IP [$server] not valid\n"); }
}

loadVendorCodes(\%vendors);

while (1) {
  my (%sccmMac, %whitelist, %adcomputer);
  my (%scopes, %reservedips, $totalscopes);
  my (%hostList, %ipList, %macList, %goodmacs);

  my ($year, $mon, $mday, $hour, $min) = gettime();
  my $timestamp = "$year$mon$mday$hour$min";

  getMAClist( "sccm.txt", \%sccmMac, 0 ); # not sure if this'll work with current sccm.txt format
  getMAClist( "whitelist.txt", \%whitelist, 0 );
  getMAClist( "blacklist.txt", \%blacklist, 1 );
  getADnames( \%dcs, \%adcomputer ); # get computer and printer names from AD

  # initialize variables for header
  $dhcphost = "DHCP-HOST";
  my $nbhost = "NetBIOS-HOST";
  $ip = "IP";
  $lease = "Lease";
  $dhcpmac = "DHCP-MAC";
  $vendor = "VENDOR";
  my $nbmac = "NetBIOS-MAC";
  $alive = "Ping";
  my $encase = "P4445";
  my $cshare = "C\$";
  my $sav = "SAV";
  my $epo = "EPO";
  my $port80 = "P80";
  $scopedesc = "ScopeDesc";
  my $scopecomment = "ScopeComment";
  my $server = "DHCP-Server";
  my $sccm;

  my $rogue = $timestamp."PossibleRogues.csv";
  open (my $OUTPUT, ">", $rogue) or die "Unable to open $rogue for output: $!\n";
  print $OUTPUT "\"$dhcpmac\",\"Note\",\"$dhcphost\",\"$scopedesc\",\"$scopecomment\",\"$ip\",\"$lease\",\"$vendor\",\"$nbmac\",\"$nbhost\",\"$alive\",\"$encase\",\"$cshare\",\"$sav\",\"$epo\",\"$port80\",\"$server\",\"Link\"\n";
  printandpush("Looking for possible rogue hosts at $hour:$min of $mon/$mday/$year\n\n");
  $totalcount = $foundcount = $blacklistcount = 0;

  if ($listall) {
    my $filename = $timestamp."-DHCPscopes.csv";
    open SCOPELIST, ">$filename" or die "Failed to open $filename";
    print SCOPELIST "Scope,Mask,LeaseTime,Description,Comment,Active\n";
    print STDERR "Saving DHCP scopes to $filename\n";
  }
  foreach my $server (@dhcpservers) {
    # get dhcp scopes with description and comments.  Also get reserved IPs and default gateways for each scope.
    open(SCOPES, "netsh dhcp server $server dump|") or warn "Can't get scopes and reserved IPs: $!\n";
    print STDERR "\nLoading scopes and reserved IPs from server at $server\n";
    my $count = 0;
    my (@scopelist, %scopes);
    my ($scope, $mask, $leasetime, $desc, $comment, $scopestate);

    while (<SCOPES>) { # load DHCP scopes
      if (/add scope/) {
        if ($listall) {
          print SCOPELIST "\"$scope\",\"$mask\",\"$leasetime\",\"$desc\",\"$comment\",\"$scopestate\"\n" if $scope ne '';
        }
        $leasetime = $scopestate = 0;
        ($scope, $mask, $desc, $comment) = /.+scope ([\d\.]+) ([\d\.]+).+"(.*)" "(.*)"/;
      }
      elsif (/set state (\d)/) {
        $scopestate = $1;
        if ($scopestate eq '1') { # 1 == active scope
          push @scopelist, $scope;
          $scopes{$scope} = "$desc\",\"$comment";
          $count += 1;
        }
        else { print STDERR "Skipping inactive scope $scope\t$desc\t$comment\n"; }
      }
      elsif ($scopestate eq '1') {
        #Dhcp Server 14.15.19.14 Scope 14.15.42.0 Add reservedip 14.15.42.101 001577a08c0c "WD0800493.odd.com" "for firewall rules" "BOTH"
        if ( /Add reservedip ([\d\.]+) ([\w]+) "(.*)"/) {
          $ip = $1;
          my $mac = uc($2);
          $mac =~ /([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})/;
          $reservedips{$ip} = "$1-$2-$3-$4-$5-$6";
          if ($listall) { $goodmacs{"$1-$2-$3-$4-$5-$6"} += 1; }
        }
        elsif (/optionvalue 3 IPADDRESS "([\d\.]+)"/) {
          $reservedips{$1} = "Default Gateway";
        }
        elsif (/optionvalue 51 DWORD "(\d+)"/) { # lease duration in seconds
          $leasetime = $1;
        }
      }
    }
    print STDERR "Number of active scopes loaded is $count\n\n";
    $totalscopes += $count;
    close SCOPES;

    if ($listall) {
      print SCOPELIST "\"$scope\",\"$mask\",\"$leasetime\",\"$desc\",\"$comment\",\"$scopestate\"\n";
      close SCOPELIST;
      my $filename = $timestamp."-AllDHCPnames.csv";
      open LIST, ">$filename" or die "Failed to open $filename";
      print STDERR "Saving ALL DHCP names to $filename\n";
    }
    foreach my $scope (@scopelist) {
      $scopedesc = $scopes{$scope};
      print STDERR "Searching $scope $scopes{$scope}\n";
      open (DHCPCMD, "netsh dhcp server $server scope $scope show clients 1|") or die "netsh dhcp server $server scope $scope show clients 1 command failed";
      while (<DHCPCMD>) {
        $nbmac = $nbhost = $dhcphost = $ip = $lease = $dhcpmac = $alive = $vendor = $encase = $cshare = $sav = $epo = $port80 = $sccm = "";
        if (/The command needs a valid Scope IP Address/) {
          print STDERR "netsh failed to read scopes from $server, running under priviledged account?\n";
        }
        elsif (/^\d{1,3}/) {
          my $type;
          my $goodline = 0;
          $totalcount++;
          # each record has the following format
          # IP Address      - Subnet Mask    - Unique ID           - Lease Expires        -Type -Name
          # 14.15.14.12  - 255.255.252.0  - 00-1a-4b-18-02-8a   -5/9/2010 9:20:44 AM    -D-  P-3D1053.com
          if ( ($ip, $mask, $dhcpmac, $lease, $type, $dhcphost)  # has normal lease date/time
              = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*- (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(.{17})\s*-\s*([0-9\/]+\s*[\d:]+\s*[AP]M)\s*-([DBURN])-\s*(.+)/ ) {
            $goodline = 1;
          }
          elsif ( ($ip, $mask, $dhcpmac, $lease, $type, $dhcphost) # has NEVER EXPIRES, INACTIVE, in lease field
                 = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*- (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*-\s*(.{17})\s*-\s*([\s\w]+)\s*-([DBURN])-\s*(.+)/ ) {
            while ($lease =~ s/\s$//g) {}
            $goodline = 1;
          }
          if ($goodline) {
            $dhcpmac = uc($dhcpmac); # upper case the letters in the MAC
            $dhcpmac =~ s/ //g; # remove spaces from the MAC
            $dhcphost =~ s/\.$//; # remove trailing '.' from host name
            $dhcphost =~ s/\s//g; # remove spaces from host name
            $dhcphost = uc($dhcphost);
            $dhcphost =~ /([\w\-\_]+)\.*/;
            my $shorthost = $1;
            if ($listall) {
              $vendor = getvendor(\%vendors, $dhcpmac);
              print LIST "\"$dhcphost\",\"$ip\",\"$lease\",\"$type\",\"$dhcpmac\",\"$vendor\",\"$scopedesc\",\"$server\"\n";
            }
            if (exists $adcomputer{$shorthost}) {
              if ($listall) { $goodmacs{$dhcpmac} += 1; }
              print STDERR "\tSkipped computer name [$shorthost] in AD\n" if $verbose;
            }
            elsif ($lease =~ /INACTIVE/) { print STDERR "\tSkipped inactive reservation for IP $ip\n" if $verbose; }
            elsif ($foundb4{$ip} eq $dhcpmac) { print STDERR "\tSkipped previously found IP $ip\n" if $verbose; }
            elsif (exists $blacklist{$dhcpmac}) { # Check blacklisted devices before reservedIPs
              print STDERR "\tMAC is $dhcpmac is in the blacklist\n" if $verbose;
              processblacklist();
            }
            elsif ($reservedips{$ip} eq $dhcpmac) { print STDERR "\tSkipped reserved IP $ip\n" if $verbose; }
            elsif ($reservedips{$ip} eq "Default Gateway") { print STDERR "\tSkipped Default Gateway IP $ip\n" if $verbose; }
            elsif (exists $whitelist{$dhcpmac}) { print STDERR "\tMAC is $dhcpmac is in the whitelist\n" if $verbose; }
            elsif (exists $sccmMac{$dhcpmac}) { print STDERR "\tMAC is $dhcpmac is in SCCM\n" if $verbose; }
            else {
              $alive = pinghost($ip, 2);
              $vendor = getvendor(\%vendors, $dhcpmac);
              if ($dhcphost =~ /\./) { # check domain
                if ($dhcphost !~ /\.com$/i) { # The devices should have this TLD
                  print STDERR "\n\n$dhcphost has a non .com domain\n\n";
                  push @notable, "$dhcphost has a non .com domain\n";
                  push @notable, "DHCP name:    $dhcphost\n";
                  push @notable, "IP address:   $ip\n";
                  push @notable, "Lease exp.:   $lease\n";
                  push @notable, "MAC address:  $dhcpmac\n";
                  push @notable, "Vendor OUI:   $vendor\n";
                  push @notable, "Pingable:     $alive\n";
                  push @notable, "Scope desc:   $scopedesc\n";
                  push @notable, "\n";
                }
                elsif ($dhcphost =~ /\.gov/i) { # The devices should not have this TLD
                  print STDERR "\n\n$dhcphost has a .gov domain\n\n";
                  push @notable, "$dhcphost has a .gov domain\n";
                  push @notable, "DHCP name:    $dhcphost\n";
                  push @notable, "IP address:   $ip\n";
                  push @notable, "Lease exp.:   $lease\n";
                  push @notable, "MAC address:  $dhcpmac\n";
                  push @notable, "Vendor OUI:   $vendor\n";
                  push @notable, "Pingable:     $alive\n";
                  push @notable, "Scope desc:   $scopedesc\n";
                  push @notable, "\n";
                }
              }
              $encase = pingport($ip, 4445); # encase agent
              $sav = pingport($ip, 2967); # Symantec AV agent
              $epo = pingport($ip, 591); # McAfee EPO agent
              $port80 = pingport($ip, 80); # may be a printer
              if ($alive eq "Y") {
                my %SHARE;
                my $found_by_nbtstat = '';

                if (NetShareGetInfo( "c\$", \%SHARE,$ip ) ) { $cshare = 'Y'; } #check for access to the c$ share.
                print STDERR "NBTSTATing $ip..." if $verbose;
                open(my $NBTSTAT, "nbtstat -A $ip|") or warn "NBTSTAT command failed\n";
                if ($NBTSTAT) {
                  while (<$NBTSTAT>) {
                    if (/MAC Address = (.+)/) {
                      $nbmac = uc($1);
                      chop $nbmac;
                      $found_by_nbtstat = 1;
                      print STDERR "found\n" if $verbose;
                    }
                    elsif (/\s*(.+)\s+<00>  UNIQUE/) {
                      $nbhost = uc($1);
                      $nbhost =~ s/[^\w,.-~\$]//g;
                    }
                  }
                }
                if ($found_by_nbtstat) {
                  if ($adcomputer{$nbhost} == 1) {
                    if ($listall) { $goodmacs{$dhcpmac} += 1; }
                    print STDERR "\tSkipped NETBios name [$nbhost] in AD\n" if $verbose;
                    next;
                  }
                  elsif (exists $blacklist{$nbmac}) {
                    processblacklist();
                  }
                  elsif ($foundb4{$ip} eq $nbmac) {
                    print STDERR "\tSkipped previously found IP $ip\n" if $verbose;
                    next;
                  }
                  elsif (exists $whitelist{$nbmac}) {
                    print STDERR "\tMAC is $nbmac is in the whitelist\n" if $verbose;
                    next;
                  }
                  elsif (exists $sccmMac{$nbmac}) {
                    print STDERR "\tMAC is $nbmac is in SCCM\n" if $verbose;
                    next;
                  }
                }
                else { print STDERR "not found\n" if $verbose; }
              }
              $foundb4{$ip} = $dhcpmac;
              print STDERR "\t\tFOUND host - $dhcphost with MAC = $dhcpmac\n";
              $foundcount++;
              $hostList{$dhcphost}++;
              $ipList{$ip}++;
              $macList{$dhcpmac}++;
              my $mac;
              if ($vendor eq "INVALID OUI") {
                if ($nbmac =~ /[a-f0-9\-]{17}/i) {
                  $mac = $nbmac;
                  $mac =~ s/-/%3A/g;
                  $sccm = "http://sccm/sccm/Report.asp?ReportID=37&variable=$mac";
                }
                else { $sccm = ''; }
              }
              else {
                $mac = $dhcpmac;
                $mac =~ s/-/%3A/g;
                $sccm = "http://sccm/sccm/Report.asp?ReportID=37&variable=$mac";
              }
              print $OUTPUT "\"$dhcpmac\",\"$mon/$mday/$year\",\"$dhcphost\",\"$scopedesc\",\"$ip\",\"$lease\",\"$vendor\",\"$nbmac\",\"$nbhost\",\"$alive\",\"$encase\",\"$cshare\",\"$sav\",\"$epo\",\"$port80\",\"$server\",\"$sccm\"\n";
            }
          }
        }
      }
    }
    undef @scopelist;
  }
  if ($listall) { close LIST; }
  close $OUTPUT;
  # loop is complete.  post processing output here
  my $summary = $timestamp."-Summary.txt";
  open $OUTPUT, ">", $summary;
  unless ($OUTPUT) {
    print STDERR "Failed to open $summary file: $!\n";
    $OUTPUT = &STDERR;
  }
  print STDERR "Printing output to file $summary\n";
  print $OUTPUT "Based on output stored in:\n\\\\fs02\\R2D2\\$rogue\n";
  my $count = @dhcpservers;
  print $OUTPUT "Found $foundcount host(s) out of a total of $totalcount listed in the $totalscopes DHCP scopes on $count server(s).\n";
  print $OUTPUT "$blacklistcount of those found are on the blacklist.\n\n";
  foreach my $item (@notable) {
    print $OUTPUT $item;
  }
  print $OUTPUT "\n";
  foreach my $host (keys %hostList) {
    if ($hostList{$host} > 1) { print $OUTPUT "\"$host\" is a duplicate host name which occurs $hostList{$host} times\n"; }
  }
  print STDERR "\n";
  foreach my $ip (keys %ipList) {
    print $OUTPUT "$ip is a duplicate ip address\n" if $ipList{$ip} > 1;
  }
  print STDERR "\n";
  foreach my $mac (keys %macList) {
    print $OUTPUT "$mac is a duplicate MAC address\n" if $macList{$mac} > 1;
  }
  gettime();
  print $OUTPUT "Completed at $hour:$min of $mon/$mday/$year\n";
  close $OUTPUT;

  if ($listall) {
    my $goodmacs = $timestamp."GoodMacs.csv";
    open (GOODMACS, ">$goodmacs");
    foreach my $mac (keys(%goodmacs)) {
      print GOODMACS "$mac\n" if $mac =~ /[A-F0-9]{2}-[A-F0-9]{2}-[A-F0-9]{2}-[A-F0-9]{2}-[A-F0-9]{2}-[A-F0-9]{2}/;
    }
    close GOODMACS;
  }
  gettime();
  print STDERR "Completed at $hour:$min of $mon/$mday/$year\n";
  undef @scopelist; undef %scopes; undef %reservedips; undef $totalscopes;
  undef %whitelist; undef %blacklist; undef %sccmMac;
  undef %hostList; undef %ipList; undef %macList; undef @notable; undef %adcomputer;
  if ($sleeptime == 0) { exit; }
  else { sleep $sleeptime }
}
# Subroutines

sub processblacklist {
  $foundcount++;
  $blacklistcount++;
  $foundb4{$ip} = $dhcpmac;
  $alive = pinghost($ip, 2);
  $vendor = getvendor(\%vendors, $dhcpmac);
  push @notable, "$dhcpmac is on the blacklist\n";
  push @notable, "$blacklist{$dhcpmac}\n";
  push @notable, "DHCP name:    $dhcphost\n";
  push @notable, "IP address:   $ip\n";
  push @notable, "Lease exp.:   $lease\n";
  push @notable, "MAC address:  $dhcpmac\n";
  push @notable, "Vendor OUI:   $vendor\n";
  push @notable, "Pingable:     $alive\n";
  push @notable, "Scope desc:   $scopedesc\n";
  push @notable, "\n";
}

sub showhelp {
  print STDERR <<THERE ;

           Remote Rogue Device Detector
Uses DHCP and AD to attempt to find rogue devices.

Edit the script near the top to:
    set the DHCP server(s)' IP address(es)
    Currently set to @dhcpservers

To run without options, from a command prompt enter:
r2d2.pl

Options:
  --sleep   time in seconds to wait to run again after completing.
            Default is 0 = run once and exit.  Max is 86400 (24 hours).
  --verbose print additional info to screen while running
  --update  update the vendor.txt file and exit
  --listall save all computer and printer names, DCHP scopes and leases
            while otherwise running the script normally.
  --help    print this help and exit

When run continously, only new devices are reported.

NOTE: May need to run 'netsh add helper dhcpmon.dll' for dhcp commands to work the first time.
      Need Microsoft's dsquery.exe to get computer and printer names from AD.

THERE
  exit;
}
