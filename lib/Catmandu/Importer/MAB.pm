package Catmandu::Importer::MAB;

use Catmandu::Sane;
use Moo;
use MAB::File::MAB2;
use MAB::File::MABdis;
use MAB::File::MABxml;

with 'Catmandu::Importer';

has type => ( is => 'ro', default => sub {'MAB2'} );
has id   => ( is => 'ro', default => sub {'001'} );

sub mab_generator {
    my $self = shift;

    my $file;

    given ( $self->type ) {
        when ('MAB2') {
            $file = MAB::File::MAB2->in( $self->fh );
        }
        when ('MABdis') {
            $file = MAB::File::MABdis->in( $self->fh );
        }
        when ('MABxml') {
            $file = MAB::File::MABxml->in( $self->fh );
        }
        die "unknown";
    }

    my $id = $self->id;

    sub {
        my $record = $file->next();
        return unless $record;

        my @result = ();

        push @result, [ 'LDR', undef, undef, $record->leader ];

        for my $field ( $record->fields() ) {
            my $tag = $field->tag;
            my $ind = $field->indicator();

            my @sf = ();

            # ToDo: what do these elements '_' and '' stand for?
            # push @sf , '_' , ($field->is_control_field ? $field->data : '');

            if ( defined $field->data() ) {
                push @result, [ $tag, $ind, '_', $field->data() ];
            }
            else {
                for my $subfield ( $field->subfields() ) {
                    push @sf, @{$subfield};
                }
                push @result, [ $tag, $ind, '_', '', @sf ];
            }

        }

        my $sysid = undef;

        if ( $id =~ /^00/ ) {
            $sysid = $record->field($id)->data();
        }
        elsif ( defined $id ) {
            $sysid = $record->field($id)->subfield("a");
        }

        return { _id => $sysid, record => \@result };
    };
}

sub generator {
    my ($self) = @_;
    my $type = $self->type;

    given ($type) {
        when (/^MAB2|MABdis|MABxml$/) {
            return $self->mab_generator;
        }
        die "need MAB2, MABdis or MABxml";
    }
}

=head1 NAME

Catmandu::Importer::MAB - Package that imports MAB data

=head1 SYNOPSIS

    use Catmandu::Importer::MAB;

    my $importer = Catmandu::Importer::MAB->new(file => "/foo/bar.dat", type=> "MAB2");

    my $n = $importer->each(sub {
        my $hashref = $_[0];
        # ...
    });

=head1 MAB

The parsed MAB is a HASH containing two keys '_id' containing the 001 field (or the system
identifier of the record) and 'record' containing an ARRAY of ARRAYs for every field:

 {
  'record' => [
                [
                    '001',
                    ' ',
                    '_',
                    'fol05882032 '
                ],
                [
                    245,
                    'a',
                    '_',
                    '',
                    'a',
                    'Cross-platform Perl /',
                    'c',
                    'Eric F. Johnson.'
                ],
        ],
  '_id' => 'fol05882032'
 } 

=head1 METHODS

=head2 new(file => $filename,type=>$type,[id=>$id_field])

Create a new MAB importer for $filename. Use STDIN when no filename is given. Type 
describes the sytax of the MAB records. Currently we support: MAB2, MABdis 
and MABxml.
Optionally provide an 'id' option pointing to the identifier field of the MAB record
(default 001).

=head2 count

=head2 each(&callback)

=head2 ...

Every Catmandu::Importer is a Catmandu::Iterable all its methods are inherited. The
Catmandu::Importer::MAB methods are not idempotent: MAB feeds can only be read once.

=head1 SEE ALSO

L<Catmandu::Iterable>

=cut

1;
