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
my $our_uid_thing = '';
my $our_uid_set = 0;

my $do_build_toc = 10;
my $depth_of_toc = 0;
my $toc_on_an_xml_so = 0;
my $toc_on_an_xml_at;
my $toc_last_level = 0;
my $toc_last_count = 0;
my @toc_list = ();

my @source_lines;
my $source_elin;
my $oebp_string;
my $oebp_rstring;
my @criticalfields = ('title','author','publisher','language','year','date');
my @gottenfields = ();

my @list_of__txt__of = ();
my $list_of__txt__id = {};
my $list_of__txt__cn = 0;

my @list_of__css__of = ();
my $list_of__css__id = {};
my $list_of__css__cn = 0;

my @list_of__img__of = ();
my $list_of__img__id = {};
my $list_of__img__cn = 0;

my $list_of__ftxt__yet = 0;
my $list_of__ftxt__at;

my $list_of__cvimg__yet = 0;
my $list_of__cvimg__at;

sub create_our_uid {
  my $lc_seta;
  my $lc_setb;
  my $lc_counto;

  if ( $our_uid_set > 5 ) { return; }

  $lc_seta = ['0','1','2','3','4','5','6',
    '7','8','9','a','b','c','d','e','f','g',
    'h','i','j','k','l','m','n','o','p','q',
    'r','s','t','u','v','w','x','y','z'
  ];
  $lc_setb = [@$lc_seta,'-'];
  $lc_counto = 60;
  $our_uid_thing = 'chobakepubtl:rnd:';
  $our_uid_thing .= &randompicker($lc_seta);
  while ( $lc_counto > 0.5 )
  {
    $our_uid_thing .= &randompicker($lc_setb);
    $lc_counto = int($lc_counto - 0.8);
  }
  $our_uid_thing .= &randompicker($lc_seta);
}


sub randompicker {
  my $lc_a;
  my @lc_b;
  my $lc_c;
  my $lc_d;
  $lc_a = $_[0];
  @lc_b = @$lc_a;
  $lc_a = @lc_b;
  $lc_c = ($lc_a * 8);
  $lc_d = rand($lc_c);
  $lc_d += $lc_a; $lc_d += $lc_a;
  while ( $lc_d > ( $lc_a - 0.5 ) ) { $lc_d = int(($lc_d - $lc_a) + 0.2); }
  return ($lc_b[$lc_d]);
}

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

  if ( &amongval($lc_tp,@criticalfields) )
  {
    $protometa->{$lc_tp} = $lc_cn;
    @gottenfields = (@gottenfields,$lc_tp);
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

  if ( $lc_tp eq 'cvimg' )
  {
    return &import_of__cvimg__do($lc_cn);
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
    return &import_of__cont__do($lc_cn);
  }

  if ( $lc_tp eq 'buildtoc' )
  {
    if ( $lc_cn eq 'on' ) { $do_build_toc = 10; return; }
    if ( $lc_cn eq 'off' ) { $do_build_toc = 0; return; }
    die("\nValue of 'buildtoc' field must be 'on' or 'off'.\n\n");
  }

  die("\nNo such recipe line type: " . $lc_tp . ":\n");
}



&create_our_uid();


{
  my $lc_a;
  my @lc_b;
  @lc_b = (@criticalfields,'ftext','cvimg');
  foreach $lc_a (@lc_b) { &verif_crit_field($lc_a); }
}
sub verif_crit_field {
  my $lc_a;
  foreach $lc_a (@gottenfields)
  {
    if ( $lc_a eq $_[0] ) { return; }
  }
  die("\nField Not Specified in Recipe File: " . $_[0] . " :\n\n");
}
sub found_crit_field {
  my $lc_a;
  foreach $lc_a (@gottenfields)
  {
    if ( $lc_a eq $_[0] ) { return (2>1); }
  }
  return(1>2);
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

open CONTENTOPF,("| cat > " . &wraprg::bsc(($build_dir . '/OEBPS/content.opf')));

print CONTENTOPF "<?xml version='1.0' encoding='utf-8'?>" . '
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="uuid_id">
<metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
<dc:language>' . &vanso('language') . '</dc:language>
<dc:title>' . &vanso('title') . '</dc:title>
<dc:creator opf:file-as="' . &vanso('author') . '" opf:role="aut">' . &vanso('author') . '</dc:creator>
<meta name="cover" content="cover"/>
<dc:date>' . &vanso('date') . '</dc:date>
<dc:publisher>' . &vanso('publisher') . '</dc:publisher>
<dc:contributor opf:role="bkp"></dc:contributor>
<dc:identifier id="uuid_id" opf:scheme="uuid">' . $our_uid_thing . '</dc:identifier>
</metadata>
<manifest>
';

sub megamyme {
  return &wraprg::abro(('file --mime-type -b ' . &wraprg::bsc(($build_dir . '/OEBPS/' . $_[0]))));
}

{
  my $lc_a;
  my $lc_mt;

  $lc_mt = &megamyme($list_of__cvimg__at);
  print CONTENTOPF '<item href="' . $list_of__cvimg__at .
      '" id="cover" media-type="' . $lc_mt . '"/>' . "\n"
    ;

  foreach $lc_a (@list_of__img__of)
  {
    $lc_mt = &megamyme($list_of__img__id->{$lc_a});
    print CONTENTOPF '<item href="' . $lc_a .
      '" id="' . $list_of__img__id->{$lc_a} .
      '" media-type="' . $lc_mt . '"/>' . "\n"
    ;
  }

  foreach $lc_a (@list_of__css__of)
  {
    print CONTENTOPF '<item href="' . $lc_a .
      '" id="' . $list_of__css__id->{$lc_a} .
      '" media-type="text/css"/>' . "\n"
    ;
  }

  print CONTENTOPF '<item href="' . $list_of__ftxt__at .
      '" id="coverpage" media-type="application/xhtml+xml"/>' . "\n"
    ;

  foreach $lc_a (@list_of__txt__of)
  {
    print CONTENTOPF '<item href="' . $lc_a .
      '" id="' . $list_of__txt__id->{$lc_a} .
      '" media-type="application/xhtml+xml"/>' . "\n"
    ;
  }
}

print CONTENTOPF '<item href="toc.ncx" media-type="application/x-dtbncx+xml" id="ncx"/>
</manifest>
<spine toc="ncx">
<itemref idref="coverpage"/>
';

{
  my $lc_a;
  $lc_a = 1;
  while ( $lc_a < ( $list_of__txt__cn + 0.5 ) )
  {
    print CONTENTOPF '<itemref idref="rtex_' . $lc_a . '_id"/>' . "\n";
    $lc_a = int($lc_a + 1.2);
  }
}

print CONTENTOPF '</spine>
<guide>
<reference href="' . $list_of__ftxt__at . '" type="cover" title="Cover"/>
</guide></package>
';

close CONTENTOPF;


# Finally, we build the Table of Contents:
if ( $do_build_toc > 5 )
{
  my $lc_node;
  my $lc_lvl;
  my $lc_nidnc;
  $toc_last_level = 0; # Have to reset it for this operation:
  $lc_nidnc = 0;

  open TOCO,("| cat > " . &wraprg::bsc(($build_dir . '/OEBPS/toc.ncx')));

  print TOCO "<?xml version='1.0' encoding='utf-8'?>" . '
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="' . &vanso('language') . '">
<head>
<meta content="' . $our_uid_thing . '" name="dtb:uid"/>
<meta content="' . $depth_of_toc . '" name="dtb:depth"/>
<meta content="chobakepubtl" name="dtb:generator"/>
<meta content="0" name="dtb:totalPageCount"/>
<meta content="0" name="dtb:maxPageNumber"/>
</head>
<docTitle>
<text>' . &vanso('title') . '</text>
</docTitle>
<navMap>
';

  foreach $lc_node (@toc_list)
  {
    $lc_lvl = $lc_node->{'lvl'};
    while ( $toc_last_level > ( $lc_lvl - 0.5 ) )
    {
      print TOCO "</navPoint>\n";
      $toc_last_level = int($toc_last_level - 0.8);
    }
    while ( $toc_last_level < ( $lc_lvl - 0.5 ) )
    {
      $lc_nidnc = int($lc_nidnc + 1.2);
      $lc_node->{'idnu'} = 'navig_' . $lc_nidnc . '_id';
      $lc_node->{'ordnu'} = $lc_nidnc;
      print TOCO "<navPoint";
      print TOCO ' id="' . $lc_node->{'idnu'} . '"';
      print TOCO ' playOrder="' . $lc_node->{'ordnu'} . '"';
      print TOCO ">\n";
      $toc_last_level = int($toc_last_level + 1.2);
    }

    #print TOCO ( $lc_node->{'title'} . " : " . $lc_lvl . "\n" );

    print TOCO "<navLabel>\n<text>";
    print TOCO $lc_node->{'title'};
    print TOCO "</text>\n</navLabel>\n";
    print TOCO '<content src="' . $lc_node->{'ref'} . '"/>' . "\n";

  }
  while ( $toc_last_level > 0.5 )
  {
    print TOCO "</navPoint>\n";
    $toc_last_level = int($toc_last_level - 0.8);
  }

  print TOCO "</navMap>\n</ncx>\n";
  close TOCO;
}


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

  @list_of__css__of = (@list_of__css__of,$_[0]);
  $list_of__css__cn = int($list_of__css__cn + 1.2);
  $list_of__css__id->{$_[0]} = ( 'styl_' . $list_of__css__cn . '_id' );
}

sub import_of__img__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);

  @list_of__img__of = (@list_of__img__of,$_[0]);
  $list_of__img__cn = int($list_of__img__cn + 1.2);
  $list_of__img__id->{$_[0]} = ( 'image_' . $list_of__img__cn . '_id' );
}

sub import_of__cvimg__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);

  if ( &found_crit_field('cvimg') )
  {
    die "\nILLEGAL for two lines of type 'cvimg':\n\n";
  }
  @gottenfields = (@gottenfields,'cvimg');
  $list_of__cvimg__yet = 10;
  $list_of__cvimg__at = $_[0];
}

sub import_of__ftext__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);

  # For TOC Generator, we must know what page we are on.
  $toc_on_an_xml_so = 10;
  $toc_on_an_xml_at = $_[0];

  if ( &found_crit_field('ftext') )
  {
    die "\nILLEGAL for two lines of type 'ftext':\n\n";
  }
  @gottenfields = (@gottenfields,'ftext');
  $list_of__ftxt__yet = 10;
  $list_of__ftxt__at = $_[0];
}

sub import_of__text__do {
  my $lc_dst;
  $lc_dst = ($build_dir . $oebp_string . '/' . $_[0]);
  system('mkdir','-p',$lc_dst);
  system('rmdir',$lc_dst);
  system('cp',&wraprg::rel_sm($source_fdir,$_[0]),$lc_dst);

  # For TOC Generator, we must know what page we are on.
  $toc_on_an_xml_so = 10;
  $toc_on_an_xml_at = $_[0];

  @list_of__txt__of = (@list_of__txt__of,$_[0]);
  $list_of__txt__cn = int($list_of__txt__cn + 1.2);
  $list_of__txt__id->{$_[0]} = ( 'rtex_' . $list_of__txt__cn . '_id' );
}

sub import_of__cont__do {
  my $lc_lvl;
  my $lc_taglt;
  my $lc_title;
  my $lc_node;
  ($lc_lvl,$lc_taglt,$lc_title) = split(/:/,$_[0],3);

  if ( $lc_lvl < 0.5 )
  {
die "
ILLEGAL:
  The value of the first argument of a 'cont' line must
  not be less than 1.

";
  }

  if ( ( $lc_lvl - $toc_last_level ) > 1.5 )
  {
die "
ILLEGAL:
  Jump of TOC level from " . $toc_last_level . " to " . $lc_lvl . "
  exceeds then maximum 1-level increase allowed per TOC entry.

";
  }
  $toc_last_level = $lc_lvl;

  if ( $toc_on_an_xml_so < 5 )
  {
    die "
ILLEGAL:
  The first 'cont' line in the recipe file may not come
  before the first page source reference in the recipe
  file (which would be either a 'text' line or an
  'ftext' line).

";
  }

  $toc_last_count = int($toc_last_count + 1.2);
  $lc_node = {
    'lvl' => $lc_lvl,
    'idn' => ( 'toc_item_' . $toc_last_count . '_id' ),
    'title' => $lc_title,
    'ref' => ( $toc_on_an_xml_at . '#' . $lc_taglt ),
    'playorder' => $toc_last_count,
  };
  if ( $lc_taglt eq '*' )
  {
    $lc_node->{'ref'} = $toc_on_an_xml_at;
  }
  @toc_list = (@toc_list,$lc_node);

  if ( $lc_lvl > $depth_of_toc ) { $depth_of_toc = $lc_lvl; }
}

sub vanso {
  my $lc_each;
  foreach $lc_each (@gottenfields)
  {
    if ( $lc_each eq $_[0] ) { return $protometa->{$_[0]}; }
  }
  die("\nErroneous Field: " . $_[0] . " :\n\n");
}






