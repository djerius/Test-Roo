use 5.008001;
use Test2::Roo;

test first_test => sub {
    pass("first");
};

test second_test => sub {
    pass("second");
};

run_me;
done_testing;

# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
