package Catmandu::Fix::mab_xml;

use Catmandu::Sane;
use Catmandu::Util qw(:is :data);
use Moo;

has path => ( is => 'ro', required => 1 );
has key  => ( is => 'ro', required => 1 );

around BUILDARGS => sub {
    my ( $orig, $class, $path ) = @_;
    my ( $p, $key ) = parse_data_path($path) if defined $path && length $path;
    $orig->( $class, path => $p, key => $key );
};

# Transform a raw MAB array into MABxml
sub fix {
    my ( $self, $data ) = @_;

    my $path = $self->path;
    my $key  = $self->key;

    my $match
        = [ grep ref, data_at( $path, $data, key => $key, create => 1 ) ]
        ->[0];

    my $mabxml;

    for my $f ( @{ $data->{record} } ) {
        my ( $tag, $ind, @data ) = @$f;

        if ( $tag eq 'LDR' ) {
            $mabxml .= mab_header( $data[1] );
        }
        else {
            $mabxml .= mab_datafield( $tag, $ind, @data );
        }
    }

    $mabxml .= mab_footer();

    $match->{$key} = $mabxml;

    $data;
}

sub mab_header {
    '<datensatz xmlns="http://www.ddb.de/professionell/mabxml/mabxml-1.xsd" typ="'
        . substr( $_[0], -1 )
        . '" status="'
        . substr( $_[0], 5, 1 )
        . '" mabVersion="M2.0">';
}

sub mab_datafield {
    my ( $tag, $ind, @subfields ) = @_;
    my $buffer
        = "<feld nr=\""
        . xml_escape($tag)
        . "\" ind=\""
        . xml_escape($ind) . "\">";

    if ( $subfields[1] ) {
        $buffer .= xml_escape( $subfields[1] );
    }
    else {
        while (@subfields) {
            my ( $n, $v ) = splice( @subfields, 0, 2 );
            next unless $n =~ /[A-Za-z0-9]/;
            $buffer
                .= "<uf code=\""
                . xml_escape($n) . "\">"
                . xml_escape($v) . "</uf>";
        }
    }
    $buffer .= "</feld>";
    $buffer;
}

sub mab_footer {
    '</datensatz>';
}

sub xml_escape {
    local $_ = $_[0];
    s/&/\&amp;/g;
    s/</\&lt;/g;
    s/>/\&gt;/g;
    s/'/\&apos;/g;
    s/"/\&quot;/g;
    $_;
}

=head1 NAME

Catmandu::Fix::mab_xml - transform a Catmandu MARC record into MARCXML

=head1 SYNOPSIS
   
   # Transforms the 'record' key into an MABxml string
   mab_xml('record');

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
