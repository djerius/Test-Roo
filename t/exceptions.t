use 5.008001;
use Test2::V0;
use Capture::Tiny 0.12 qw/capture/;

use lib 't/lib';

my @cases = (
    {
        label  => "missing role",
        file   => "t/bin/role-not-found.pl",
        expect => qr/Can't \S+ RoleNotFoundAnywhere\.pm in \@INC/,
    },
    {
        label  => "requires not satisfied",
        file   => "t/bin/unsatisfied.pl",
        expect => qr/Can't apply RequiresFixture to main/,
    },
    {
        label  => "Test2::Roo loads strictures",
        file   => "t/bin/not-strict.pl",
        expect => qr/requires explicit package name/,
    },
    {
        label   => "skip_all respected",
        file    => "t/bin/skip-all.pl",
        expect  => qr/We just want to skip/,
        exit_ok => 1,
        stdout  => 1,
    },
    {
        label   => "skip_all respected in role",
        file    => "t/bin/skip-in-role.pl",
        expect  => qr/We just want to skip/,
        exit_ok => 1,
        stdout  => 1,
    },
);

for my $c (@cases) {
    my ( $output, $error, $rc ) = capture { system( $^X, $c->{file} ) };
    subtest $c->{label} => sub {
        if ( $c->{exit_ok} ) {
            ok( !$rc, "exit ok" );
        }
        else {
            ok( $rc, "nonzero exit" );
        }
        like( $c->{stdout} ? $output : $error, $c->{expect}, "exception text" );
    };
}

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
