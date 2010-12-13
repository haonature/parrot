#!perl
# Copyright (C) 2006, Parrot Foundation.

use strict;
use warnings;

use lib qw(. lib ../lib ../../lib );

use Test::More;
use Parrot::Test;
use Parrot::Config;

=head1 NAME

t/src/string.t - Parrot API string operations

=head1 SYNPOSIS

    % prove t/src/string.t

=head1 DESCRIPTION

Tests string API support.

=cut

# generic tests

plan tests => 1;

c_output_is( <<'CODE', <<'OUTPUT', "wchar import / export" );

#include <parrot/parrot.h>
#include <parrot/embed.h>
#include <parrot/api.h>
#include <stdio.h>

#define TEST_STR "The quick brown fox jumps over the lazy dog"
#define TEST_STR_L L"The quick brown fox jumps over the lazy dog"

int main(int argc, char* argv[])
{
    Parrot_Interp interp = Parrot_new(NULL);
    Parrot_PMC pmc = Parrot_pmc_new(interp, enum_class_ParrotInterpreter);

    Parrot_String str = NULL;
    Parrot_api_string_import_wchar(pmc, TEST_STR_L, &str);

    if (strcmp(Parrot_str_to_cstring(interp, str), TEST_STR) != 0) {
        printf("Failed to import a wchar string into a Parrot_string");
        return EXIT_FAILURE;
    }

    printf("ok 1\n");

    wchar_t *wcout;
    Parrot_api_string_export_wchar(pmc, str, &wcout);
    Parrot_pmc_destroy(interp, pmc);

    if (wcscmp(wcout, TEST_STR_L) != 0) {
        printf("Failed to export a wchar string from a Parrot_string");
        return EXIT_FAILURE;
    }

    printf("ok 2\n");

    return EXIT_SUCCESS;
}
CODE
ok 1
ok 2
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
