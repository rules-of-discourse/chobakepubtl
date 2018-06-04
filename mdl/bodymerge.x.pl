use strict;
use argola;
use wraprg;

my @list_of_css = ();
my @list_of_xhtml = ();
my $thettl = "Generic Page";
my $eachofile;

sub opto__css__do {
  @list_of_css = (@list_of_css,&argola::getrg());
} &argola::setopt('-css',\&opto__css__do);

sub opto__l__do {
  my $lc_fl;
  while ( &argola::yet() )
  {
    $lc_fl = &argola::getrg();
    if ( -f $lc_fl )
    {
      @list_of_xhtml = (@list_of_xhtml,$lc_fl);
    }
  }
} &argola::setopt('-l',\&opto__l__do);

sub opto__ttl__do {
  $thettl = &argola::getrg();
} &argola::setopt('-ttl',\&opto__ttl__do);

&argola::runopts();

print '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>';
print $thettl . "</title>\n";

foreach $eachofile (@list_of_css)
{
  print '<link href="' . $eachofile;
  print '" type="text/css" rel="stylesheet"/>' . "\n";
}
print '</head>
<body>
';

foreach $eachofile (@list_of_xhtml)
{
  my $lc_cm;
  my $lc_aa;
  my $lc_ab;
  my $lc_ac;
  my $lc_con;
  my $lc_bod;
  $lc_cm = 'cat ' . &wraprg::bsc($eachofile);
  $lc_con = `$lc_cm`;
  ($lc_aa,$lc_ab) = split(quotemeta('<body>'),$lc_con);
  ($lc_bod,$lc_ac) = split(quotemeta('</body>'),$lc_ab);
  print $lc_bod . "\n";
}

print '
</body>
</html>
';

