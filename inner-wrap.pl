use strict;
use argola;
use plelorec;
use File::Basename;
use Cwd qw(realpath);

my $ourdiro;
my $modul;
my $mdfound = 0;
my $mdats;
my @argpass;

$ourdiro = dirname(realpath($0));

if ( !(&argola::yet()) ) { die "\nNot enough arguments.\n\n"; }

$modul = &argola::getrg();

if ( $mdfound < 5 )
{
  my $lc_a;
  $lc_a = $ourdiro . '/mdl/' . $modul . '.x.pl';
  if ( -f $lc_a )
  {
    $mdfound = 10;
    $mdats = $lc_a;
  }
}


if ( $mdfound < 5 ) { die("\nNo such module: " . $modul . ":\n\n"); }
@argpass = ($mdats);
while ( &argola::yet() )
{
  @argpass = (@argpass,&argola::getrg());
}
&plelorec::flplex(@argpass);




