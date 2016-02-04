
use v6;
use lib <blib/lib lib>;

use Test;

plan 8;

use Control::Bail;

my $*d;
sub normal_return_trail {
    trail { $*d = 'normal_return_trail' };
}
sub normal_return_bail {
    bail { $*d = 'normal_return_bail' };
}
sub normal_return_trail-keep {
    trail-keep { $*d = 'normal_return_trail-keep' };
}

normal_return_trail();
is $*d, 'normal_return_trail', "Normal returns run trail clauses";
normal_return_bail();
isnt $*d, 'normal_return_bail', "Normal returns do not run bail clauses";
normal_return_trail-keep();
is $*d, 'normal_return_trail-keep', "Normal returns run trail-keep clauses";

sub abnormal_return_trail {
    trail { $*d = 'abnormal_return_trail' };
    fail "abnormally";
    1;
}
sub abnormal_return_bail {
    bail { $*d = 'abnormal_return_bail' };
    fail "abnormally";
    1;
}
sub abnormal_return_trail-keep {
    trail-keep { $*d = 'abnormal_return_trail-keep' };
    fail "abnormally";
    1;
}

$ = abnormal_return_bail();
is $*d, 'abnormal_return_bail', "Abnormal returns run bail clauses";
$ = abnormal_return_trail();
is $*d, 'abnormal_return_trail', "Abnormal returns run trail clauses";
$ = abnormal_return_trail-keep();
isnt $*d, 'abnormal_return_trail-keep', "Abnormal returns do not run trail-keep clauses";


# Really this is just testing the leave queue itself but JIC
$*d = '';
sub normal_return_2trail {
    trail { $*d ~= '1' };
    trail { $*d ~= '2' };
}
normal_return_2trail();
is $*d, "21", "trail lifo";

# Really this is just testing the leave queue itself but JIC
$*d = '';
sub normal_return_trail_LEAVE {
    LEAVE { $*d ~= '1' };
    trail { $*d ~= '2' };
}
normal_return_trail_LEAVE();
is $*d, "21", "trail plus LEAVE lifo";
