Perl6-Control-Bail
========

Control::Bail:: Perl 6 module for deferred error cleanup

## Purpose

The Control::Bail module allows nested allocations of resources to be
released in an orderly fashion, without repeating yourself, with no deep
block nesting and with deallocation code placed next to the corresponding
allocation code.

## Status

Brand spanking new.  Let the bikeshedding commence.  Also, uses a lot
of metamodel/internal stuff that is not necessarily nailed down by
specification.

## Idioms

```perl6
# This DWYW.  No need to test $skel or $thing to see whether or
# not they were allocated, works in reverse order of bail statements,
# and no bail statements get run when successful.
sub make_thing {
    my $skel = make_skeleton();
    $skel or die "Could not make skeleton";
    bail { destroy_skeleton($skel); }

    my $thing = make_skin($skel);
    $thing or die "Could not make skin";
    bail { destroy_skin($thing); }

    Bool.pick or die("Unpredicable failure");
    $thing;
}

# In the following code:
# If there was a touchdown there is cheering
# ...then...
# The Receiver gets an icepack, but only if he was tackled.
# ...then...
# The Receiver always gets juice, unless the QB was sacked.
# ...then...
# The QB always gets taunted, unless there was a touchdown.
# ...then...
# If there was no touchdown, the failure is thrown.
use Control::Bail;
sub towlboy {
    bail { say "Taunt the QB" }
    Bool.pick or die "sacked!";
    trail { say "Bring Receiver juice" }
    bail { say "Bring Receiver icepack" }
    Bool.pick or die "tackled!";
    say "touchdown!";
}
towlboy();
```