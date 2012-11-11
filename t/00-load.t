#!perl -T

use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'Catmandu::Importer::MAB';
    use_ok 'Catmandu::Fix::mab_map';
    use_ok 'Catmandu::Fix::mab_xml';
    use_ok 'Catmandu::Fix::mab_in_json';
}

require_ok 'Catmandu::Importer::MAB';
require_ok 'Catmandu::Fix::mab_map';
require_ok 'Catmandu::Fix::mab_xml';
require_ok 'Catmandu::Fix::mab_in_json';

done_testing 8;
