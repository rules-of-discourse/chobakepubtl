use strict;
use argola;
use wraprg;
use File::Basename;
use Cwd qw(realpath);


my $source_file;
my $build_dir;
my $oebp_cm_arg;
my $epub_bnom;

my $source_fdir;
my $source_cont;
my $book_loc_epub;
my $protometa; # Hashref of all proto-metadata

my $resdir;

my @source_lines;
my $source_elin;
my $oebp_string;
my $oebp_rstring;

$resdir = ( dirname(dirname(realpath($0))) . '/res');
$protometa = {};

$source_file = &argola::getrg();
$build_dir = &argola::getrg();
$oebp_cm_arg = 'OEBPS';
if ( !(argola::yet()) ) { die "\nNot enough arguments.\n\n"; }
$epub_bnom = &argola::getrg();

&set_the_oebg_string();
sub set_the_oebg_string {
  my $lc_a;
  $oebp_string = '';
  $oebp_rstring = '';
  if ( $oebp_cm_arg eq '.' ) { return; }
  if ( $oebp_cm_arg eq '' ) { &oebp_illegal(); }
  $lc_a = substr $oebp_cm_arg, 0 , 1;
  if ( $lc_a eq '.' ) { &oepb_illegal(); }
  $oebp_string = '/' . $oebp_cm_arg;
  $oebp_rstring = $oebp_cm_arg . '/';
}
sub oepb_illegal {
  die "\nIllegal OEBPS value.\n\n";
}

if ( ! ( -f $source_file ) )
{
  die("\nNo such source file: " . $source_file . ":\n\n");
}
$source_fdir = dirname(realpath($source_file));


{
  my $lc_dr;
  my $lc_adr;
  my $lc_fbas;
  $lc_dr = dirname($epub_bnom);
  if ( ! ( -d $lc_dr ) )
  {
    die("\nNo such directory: " . $lc_dr . " :\n\n");
  }
  $lc_adr = realpath($lc_dr);
  ($lc_fbas) = fileparse($epub_bnom);
  $book_loc_epub = $lc_adr . '/' . $lc_fbas . '.epub';
}


$source_cont = &wraprg::abro('cat ' . &wraprg::bsc($source_file));

system('rm','-rf',$build_dir);
system('mkdir',$build_dir);
#system('mkdir',($build_dir . '/OEBPS'));
#system('mkdir',($build_dir . '/OEBPS/Images'));
#system('mkdir',($build_dir . '/OEBPS/Text'));
#system('mkdir',($build_dir . '/OEBPS/Styles'));
system('mkdir',($build_dir . '/META-INF'));
system("echo -n 'application/epub+zip' > " . &wraprg::bsc(($build_dir . '/mimetype')));

@source_lines = split(/\n/,$source_cont);
foreach $source_elin (@source_lines)
{
  &eachlin($source_elin);
}
sub eachlin {
  my $lc_tp;
  my $lc_cn;
  ($lc_tp,$lc_cn) = split(/:/,$_[0],2);

  if ( &amongval($lc_tp,'title','author','publisher','language','year') )
  {
    $protometa->{$lc_tp} = $lc_cn;
    return;
  }

  if ( $lc_tp eq 'css' )
  {
    return &import_of__css__do($lc_cn);
  }

  if ( $lc_tp eq 'img' )
  {
    return &import_of__img__do($lc_cn);
  }

  if ( $lc_tp eq 'ftext' )
  {
    return &import_of__ftext__do($lc_cn);
  }

  if ( $lc_tp eq 'text' )
  {
    return &import_of__text__do($lc_cn);
  }

  if ( $lc_tp eq 'cont' )
  {
    return;
  }

  die("\nNo such recipe line type: " . $lc_tp . ":\n");
}

open CONTAINXML,("| cat > " . &wraprg::bsc(($build_dir . '/META-INF/container.xml')));

print CONTAINXML '<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles>
<rootfile full-path="';

print CONTAINXML $oebp_rstring;

print CONTAINXML 'content.opf" media-type="application/oebps-package+xml"/>

</rootfiles></container>';

close CONTAINXML;


# Finally, having prepared everything in the build directory,
# it is now time to zip it all into the EPUB.
{
  my $lc_cm;
  $lc_cm = '( cd ' . &wraprg::bsc($build_dir) . ' && zip ';
  $lc_cm .= &wraprg::bsc($book_loc_epub) . ' -r -D -X';
  #$lc_cm .= ' *';
  $lc_cm .= ' mimetype OEBPS META-INF';
  $lc_cm .= ' )';
  system('rm','-rf',$book_loc_epub);
  system($lc_cm);
}


# ################################################ #
# ##  ONLY UTILITY FUNCTIONS BEYOND THIS POINT  ## #
# ################################################ #


sub amongval {
  my $lc_rg;
  my $lc_ref;
  my $lc_new;
  $lc_new = 10;
  foreach $lc_rg (@_)
  {
    if ( $lc_new > 5 ) { $lc_ref = $lc_rg; }
    if ( $lc_new < 5 )
    {
      if ( $lc_ref eq $lc_rg ) { return(2>1); }
    }
    $lc_new = 0;
  }
  return(1>2);
}

sub import_of__css__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);
}

sub import_of__img__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);
}

sub import_of__ftext__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);
}

sub import_of__text__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);
}






