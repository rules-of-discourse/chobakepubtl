use argola;
use Cwd 'abs_path';
use File::Basename;

my $dirloc;
my @cmdon;

$dirloc = dirname(dirname(abs_path($0)));

$semapa = 'b';
if ( -f ( $dirloc . '/bnr-flag.txt' ) ) { $semapa = 'a'; }

if ( !(&argola::yet()) )
{
  die "\nNo binary command to run?\n\n";
}

@cmdon = ();
@cmdon = (($dirloc . '/bnr-' . $semapa . '/' . &argola::getrg()));
while ( &argola::yet() )
{
  @cmdon = (@cmdon,&argola::getrg());
}


exec(@cmdon);


