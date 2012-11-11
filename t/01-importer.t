#!perl -T

use strict;
use warnings;

use Catmandu::Importer::MAB;
use Test::Simple tests => 2;

my $importer = Catmandu::Importer::MAB->new( file => 't/records.dat', type => "MAB2" );

my @records;

my $n = $importer->each(
    sub {
        push( @records, $_[0] );
    }
);

ok( $records[0]->{'_id'} eq '2273477-6', 'importer: $hashref->{\'_id\'}' );
ok( $records[0]->{'_id'} eq $records[0]->{'record'}->[1][-1],
    'importer: $hashref->{\'_id\'} eq $hashref->{\'record\'}->[1][-1]'
);