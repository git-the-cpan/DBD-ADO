#!perl -I./t

$| = 1;

use strict;
use warnings;
use DBI();
use ADOTEST();

use Test::More;

if (defined $ENV{DBI_DSN}) {
  plan tests => 16;
} else {
  plan skip_all => 'Cannot test without DB info';
}

pass('Attribute tests');

my $dbh = DBI->connect or die "Connect failed: $DBI::errstr\n";
pass('Database connection created');

my $tbl = $ADOTEST::table_name;

my $sth = $dbh->prepare("SELECT A FROM $tbl");
$sth->execute;

# TODO:
#
# DBI 1.43: getting or setting an invalid attribute to no longer be
#           a fatal error but generate a warning instead.
#eval {
#  my $val = $sth->{BadAttributeHere};
#};
#ok( $@,"Statement attribute BadAttributeHere: $@");

my @attribs = qw(
NUM_OF_FIELDS
NUM_OF_PARAMS
NAME NAME_lc
NAME_uc
PRECISION
SCALE
NULLABLE
CursorName
Statement
RowsInCache
);

for my $attrib ( sort @attribs ) {
  eval {
    my $val = $sth->{$attrib};
  };
  ok(!$@,"Statement attribute: $attrib");
}

my $val = -1;
ok(  $val = ( $sth->{RowsInCache}    = 100 ),"Setting RowsInCache : $val");
ok( ($val =   $sth->{RowsInCache} ) == 100  ,"Getting RowsInCache : $val");

$sth->finish;

ok( $dbh->disconnect,'Disconnect');
