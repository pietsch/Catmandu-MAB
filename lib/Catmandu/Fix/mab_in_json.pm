package Catmandu::Fix::mab_in_json;

use Catmandu::Sane;
use Moo;

# Transform a raw MAB array into MAB-in-JSON
# See Ross Singer work at:
#  http://dilettantes.code4lib.org/blog/2010/09/a-proposal-to-serialize-marc-in-json/
sub fix {
    my ( $self, $data ) = @_;

    my $mij = {};

    # _id is not a valid MAB-in-JSON element
    # $mij->{_id} = $data->{_id};

    for my $f ( @{ $data->{record} } ) {
        my ( $tag, $ind, @data ) = @$f;

        if ( $tag eq 'LDR' ) {
            $mij->{leader} = $data[1];
        }
        elsif ( $data[0] eq '_' ) {

            # shift @data;
            push @{ $mij->{fields} },
                { $tag => { data => $data[1], ind => $ind } };
        }
        else {
            my @subfields = ();

            # for (my $i = 2 ; $i < @data ; $i += 2) {
            # push @subfields , { $data[$i] => $data[$i+1] };
            # }
            while ( defined( my $subfield = shift @data ) ) {
                push @subfields, { $subfield => shift @data };
            }
            push @{ $mij->{fields} },
                {
                $tag => {
                    subfields => \@subfields,
                    ind       => $ind,
                }
                };
        }
    }

    $mij;
}

=head1 NAME

Catmandu::Fix::mab_in_json - transform a Catmandu MAB record into MAB-in-JSON

=head1 SYNOPSIS

   # Create a deeply nested key
   mab_in_json();

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
