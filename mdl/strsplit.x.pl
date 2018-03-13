
# Copyright (c) 2018 - Sophia Elizabeth Shapira
# This script is licensed under the terms of the GNU General
# Public License version 2.0 or later.

use strict;
use argola;
my @arglist;
my $sourcest;
my $patst;
my @parts;
my $dfil;

#@arglist = @ARGV;
#if ( &counto(@arglist) < 2.5 ) { die "\nNot enough arguments.\n\n"; }
sub counto {
  my $lc_a;
  $lc_a = @_;
  return $lc_a;
}

$sourcest = &argola::getrg();
$patst = &argola::getrg();
if ( !(&argola::yet()) ) { die "\nNot enough arguments.\n\n"; }
@arglist = ();
while ( &argola::yet() )
{
  @arglist = (@arglist,&argola::getrg());
}

@parts = split(quotemeta($patst),$sourcest);

foreach $dfil (@arglist) { &zando($dfil); }
sub zando {
  my $lc_arg;
  if ( &counto(@parts) < 0.5 ) { return; }
  $lc_arg = shift(@parts);
  open TAK,("| cat > " . $_[0]);
  print TAK $lc_arg . "\n";
  close TAK;
}

