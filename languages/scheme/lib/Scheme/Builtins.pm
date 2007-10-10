# $Id$
# Copyright (C) 2002-2007, The Perl Foundation.

package Scheme::Builtins;

# pragmata
use strict;
use warnings;
use 5.008;

# nice for debugging
use Data::Dumper;

my %built_ins = (
    write => [
        [ '', '#', 'Write function' ],
        [ '', '.sub',        'write' ],
        [ '', '.param pmc',  'arg1' ],
        [ '', '.local pmc',  'elem' ],
        [ '', 'typeof',      'I0', 'arg1' ],
        [ '', 'ne',          'I0', '.Undef', 'write_N_UNDEF' ],
        [ '', 'print',       '"()"' ],
        [ '',                'branch', 'write_FINISHED' ],
        [ 'write_N_UNDEF',   'ne',     'I0', '.Integer', 'write_N_INTEGER' ],
        [ '',                'print',  'arg1' ],
        [ '',                'branch', 'write_FINISHED' ],
        [ 'write_N_INTEGER', 'ne',     'I0', '.Array', 'write_N_ARRAY' ],
        [ '',                '#', '_dumper( arg1 )' ],
        [ '',                'print',  '"("' ],
        [ 'write_NEXT',      qw( set P6 arg1 ) ],
        [ '',                qw( set arg1 P6[0] ) ],
        [ '',                'write( arg1 )' ],
        [ '',                '#',  q{} ],
        [ '',                qw( set arg1 P6[1] ) ],
        [ '',                'typeof', 'I0', 'arg1' ],
        [ '',                'eq',     'I0', '.Undef', 'write_KET' ],
        [ '',                'ne',     'I0', '.Array', 'write_DOT' ],
        [ '',                'print',  '" "' ],
        [ '',                'branch', 'write_NEXT' ],
        [ 'write_DOT',       'print',  q{" . "} ],
        [ '',                'write( arg1 )' ],
        [ 'write_KET',       'print',  '")"' ],
        [ '',                'branch', 'write_FINISHED' ],
        [ 'write_N_ARRAY',   '',  '' ],
        [ '',                'print',  'arg1' ],
        [ '',                'branch', 'write_FINISHED' ],
        [ 'write_FINISHED', '' ],
        [ '', '.end' ],
    ],
    apply => [
        ['# Apply function'],
        [ 'apply_ENTRY', 'set',    'P0',  'P5' ],
        [ '',            'set',    'P16', 'P6' ],
        [ '',            'typeof', 'I16', 'P16' ],
        [ '',            'set',    'I1',  0 ],
        [ '',            'set',    'I2',  0 ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P5',  'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P6', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P7',  'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P8', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P9',  'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P10', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P11', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P12', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P13', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P14', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P15', 'P16[0]' ],
        [ '', 'bsr', 'apply_HELP' ],
        [ '', 'eq',  'I16', '.Undef', 'apply_CALL' ],
        [ '', 'set', 'P17', 'P16' ],
        [ 'apply_COUNT', 'ne',  'I16', '.Undef', 'apply_ARRAY' ],
        [ '',            'inc', 'I2' ],
        [ '',            'set',    'P17',     'P17[1]' ],
        [ '',            'typeof', 'I16',     'P17' ],
        [ '',            'branch', 'apply_COUNT' ],
        [ 'apply_ARRAY', 'new',    'P3',      '.Array' ],
        [ '',            'set',    'P3',      'I2' ],
        [ '',            'set',    'I16',     0 ],
        [ 'apply_ITER',  'set',    'P3[I16]', 'P16[0]' ],
        [ '',            'set',    'P16',     'P16[1]' ],
        [ '',            'inc',    'I16' ],
        [ '',           'ne',  'I16', 'I2', 'apply_ITER' ],
        [ 'apply_CALL', 'set', 'I0',  0 ],
        [ '',           'invoke' ],
        [ 'apply_HELP', 'P16', 'P16[1]' ],
        [ '',           'inc', 'I1' ],
        [ '', 'typeof', 'I16', 'P16' ],
        [ '', 'ret' ],
    ],
);

sub new {
    my $class = shift;

    my $self = { instruction => [] };
    
    return bless $self, $class;
}

sub _add_inst {
    my $self = shift;

    push @{ $self->{instruction} }, [@_];

    return;
}

sub generate {
    my ( $code, $name ) = @_;

    die "$name: Unknown builtin\n" unless exists $built_ins{$name};

    my $self = Scheme::Builtins->new();

    foreach ( @{ $built_ins{$name} } ) {
        my ( $label, $op, @args ) = @{$_};
        $self->_add_inst( $label, $op, [@args] );
    }

    return $self;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
