use 5.008001;
use strictures;

package Test2::Roo::Role;
# ABSTRACT: Composable role for Test2::Roo
# VERSION

use Test2::Roo (); # no imports!
use Sub::Install;

sub import {
    my ( $class, @args ) = @_;
    my $caller = caller;
    Sub::Install::install_sub(
        { into => $caller, code => 'test', from => 'Test2::Roo' } );
    strictures->import; # do this for Moo, since we load Moo in eval
    eval qq{
        package $caller;
        use Moo::Role;
    };
    if (@args) {
        eval qq{ package $caller; use Test2::V0 \@args };
    }
    else {
        eval qq{ package $caller; use Test2::V0 };
    }
    die $@ if $@;
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

A testing role:

    # t/lib/MyTestRole.pm
    package MyTestRole;
    use Test2::Roo::Role; # loads Moo::Role and Test2::V0

    requires 'class';

    test 'object creation' => sub {
        my $self = shift;
        require_ok( $self->class );
        my $obj  = new_ok( $self->class );
    };

    1;

=head1 DESCRIPTION

This module defines test behaviors as a L<Moo::Role>.

=head1 USAGE

Importing L<Test2::Roo::Role> also loads L<Moo::Role> (which gives you
L<strictures> with fatal warnings and other goodies).

Importing also loads L<Test2::V0>.  Any import arguments are passed through to
Test2::V0's C<import> method.

=head2 Creating and requiring fixtures

You can create fixtures with normal Moo syntax.  You can even make them lazy
if you want and require the composing class to provide the builder:

    has fixture => (
        is => 'lazy'
    );

    requires '_build_fixture';

Because this is a L<Moo::Role>, you can require any method you like, not
just builders.

See L<Moo::Role> and L<Role::Tiny> for everything you can do with roles.

=head2 Setup and teardown

You can add method modifiers around the C<setup> and C<teardown> methods and
these will be run before tests begin and after tests finish (respectively).

    before  setup     => sub { ... };

    after   teardown  => sub { ... };

You can also add method modifiers around C<each_test>, which will be
run before and after B<every> individual test.  You could use these to
prepare or reset a fixture.

    has fixture => ( is => 'lazy, clearer => 1, predicate => 1 );

    after  each_test => sub { shift->clear_fixture };

Roles may also modify C<setup>, C<teardown>, and C<each_test>, so the order
that modifiers will be called will depend on when roles are composed.  Be
careful with C<each_test>, though, because the global effect may make
composition more fragile.

You can call test functions in modifiers. For example, you could
confirm that something has been set up or cleaned up.

    before each_test => sub { ok( ! shift->has_fixture ) };

=head1 EXPORTED FUNCTIONS

Loading L<Test2::Roo::Role> exports a single subroutine into the calling package
to declare tests.

=head2 test

    test $label => sub { ... };

The C<test> function adds a subtest.  The code reference will be called with
the test object as its only argument.

Tests are run in the order declared, so the order of tests from roles will
depend on when they are composed relative to other test declarations.

=cut

# vim: ts=4 sts=4 sw=4 et:
