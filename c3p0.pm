use strict;
# c3p0.pm
# shared functions for r2d2.pl, etc.
use Net::Ping;
use LWP::Simple;

sub getMAClist {
  my $filename = shift; # input file = whitelist.txt | blacklist.txt (so far)
  my $hashref = shift; # Where the results are stored
  my $commentflag = shift; # keep comments or not.  0 = don't keep, 1 = keep. Whitelist doesn't need comments ATM.  Blacklist uses them in the Summary.txt
    my $FILE;
  if (open ($FILE, "<", $filename)) {
    print STDERR "Loading $filename\n";
    my $count = 0;
    while (<$FILE>) {
      $count += 1;
      if (my ($mac, $comment) = /^([\da-fA-F]{2}-[\da-fA-F]{2}-[\da-fA-F]{2}-[\da-fA-F]{2}-[\da-fA-F]{2}-[\da-fA-F]{2})(.*)$/) {
        $mac = uc($mac);
        if ( $commentflag ) { $$hashref{$mac} = $comment; }
        else { $$hashref{$mac} = undef; }
      }
      else { print STDERR "$filename line $count is in wrong format\n$_\n"; }
    }
    printandpush("$filename contains $count entries.\n");
  }
  else { printandpush("Unable to open $filename: $!\n"); }
  close $FILE;
}

sub getADnames {
  # get computer names from AD
  my $dcs = shift;
  my $hashref = shift;
  my $DSQUERY;
  foreach my $dc (keys(%$dcs)) {
    open ($DSQUERY, "dsquery.exe * ".$$dcs{$dc}." -s $dc -filter \"(&(samaccounttype=805306369))\" -limit 0|") 
      or warn "Unable to get computer names from $dc\n";
    if ($DSQUERY) {
      print STDERR "Loading Computer names from $dc\nNames not loaded will be displayed\n";
      my $count = 0;
      while (<$DSQUERY>) {
        if (/\"CN=([\w\-]+),/) { 
          $$hashref{uc($1)} = 1;
          $count += 1;
        }
        else { print STDERR $_; }
      }
      close $DSQUERY;
      printandpush("Number of computer names loaded from $dc is $count\n");
    }
    # get printer names from AD
    open ($DSQUERY, "dsquery.exe * ".$$dcs{$dc}." -s $dc -filter \"(&(objectClass=PrintQueue))\" -limit 0 -attr PrinterName|")
      || warn "Unable to get printer names from $dc\n";
    if ($DSQUERY) {
      print STDERR "Loading Printer names from $dc\nNames not loaded will be displayed\n";
      my $count = 0;
      while (<$DSQUERY>) {
        while (s/\s$//g) {}
        if (/\s+([\w\-\ ]+)/) {
          $$hashref{uc($1)} += 1;
          if ($$hashref{uc($1)} > 1) { print STDERR "Duplicate printer: $1\n"; }
          $count += 1; # change this to only count unique printer names?
        }
        else { print STDERR $_; }
      }
      close $DSQUERY;
      printandpush("Number of printer names loaded from $dc is $count\n");
		}
	}
}

sub printandpush { #### replace with TEE
  my $string = shift;
  print STDERR $string;
  push @main::notable, $string;
}

sub pingport {
  my $ip = shift;
  my $port = shift;
  my $result = '';
  unless ($port > 0 && $port < 65546) { 
    print STDERR "Bad port specified for ping test: $port\n"; 
  }
  else {
    my $p = Net::Ping->new("syn",2);
    $p->port_number($port);
    $p->ping($ip); 
    while (my ($host,$rtt,$fip) = $p->ack) {
      print "HOST: $ip ACKed port $port in $rtt seconds.\n" if $main::verbose;
      $result = 'Y';
    }
    $p->close();
  }
  return $result;
}

sub pinghost {
  my $ip = shift;
  my $count = shift;
  my $alive = 'N';
  my $p = Net::Ping->new("icmp",1);
  for (my $i = 1; $i <= $count; $i++) {
    if ($p->ping($ip)) {
      $alive = "Y";
      last;
    }
  }
  $p->close();
  return $alive;
}

sub gettime {
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $year += 1900;
  $mon += 1;
  if ($mon < 10) {$mon = "0" . $mon;}
  if ($mday < 10) {$mday = "0" . $mday;}
  if ($hour < 10) {$hour = "0" . $hour;}
  if ($min < 10) {$min = "0" . $min;}
    return ($year, $mon, $mday, $hour, $min);
}

sub loadVendorCodes {
  my $vendors = shift;
  my $VENDOR;
  # vendor.txt is for identifying the OUI of the MAC
  if (open ($VENDOR, "vendor.txt")) {
    print STDERR "Loading vendor codes\n";
    my $count = 0;
    while (<$VENDOR>) {
      chomp(my ($vendor, $desc) = split(/\,/,$_,2));
      $$vendors{$vendor} = $desc;
      $count += 1;
    }
    &printandpush("Loaded $count vendor codes\n");
  }
  else { &printandpush("Failed to load the vendor codes\n"); }
  close $VENDOR;
}
sub getvendor {
  my $vendors = shift;
  my $mac = shift;
  if (length($mac) eq 17) {
    $mac = uc($mac);
    $mac =~ s/\.//;
    my ($vendor, undef) = substr $mac,0,8;
    if (exists $$vendors{$vendor}) { return $$vendors{$vendor}; }
    else { return "UNKNOWN"; }
  }
  else { return "INVALID OUI"; }
}

sub updatevendorlist {
  my $OUT;
  my $content = get("http://standards-oui.ieee.org/oui.txt");
  die "Couldn't get it!" unless defined $content;
  my @lines = split /\n/,$content;
  if (-e "vendor.txt") {
    if (-e "vendor.old") { unlink "vendor.old"; }
    system "ren vendor.txt vendor.old";
  }
  open ($OUT, ">vendor.txt") or die;
  foreach my $line (@lines) {
    next unless $line =~ /\(hex/;
    my ($oui, $vendor) = split /   \(hex\)\t\t/,$line;
    print $OUT "$oui,$vendor\n";
  }
  close $OUT;
}

1;
