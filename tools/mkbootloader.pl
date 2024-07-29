#!/usr/bin/perl

use Term::ANSIColor;

open(SIG, $ARGV[0]) || die "open $ARGV[0]: $!";

$n = sysread(SIG, $buf, 1000);

if($n > 510){
  print STDERR colored("[ WARN ]", 'red'), " Bootloader too large: $n of 510 maximum bytes!\n";
  exit 1;
}

print STDERR colored("[ OK ]", 'green'), " Bootloader contains $n of 510 maximum bytes.\n";

$buf .= "\0" x (510-$n);
$buf .= "\x55\xAA";

open(SIG, ">$ARGV[0]") || die "open >$ARGV[0]: $!";
print SIG $buf;
close SIG;