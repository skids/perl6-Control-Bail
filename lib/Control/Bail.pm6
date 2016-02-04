=NAME Control::Bail - Defer cleanup code

=begin SYNOPSIS
=begin code

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


=end code
=end SYNOPSIS

=begin DESCRIPTION

Using this module adds three control statements to Perl6 syntax:

The C<bail> statement places the closure following it onto the
C<LEAVE> queue, like the C<UNDO> phaser -- the closures will
be run only if the current block exits unsuccessfully.

Unlike the C<UNDO> phaser, it does so at runtime, and so closures
are not placed on the C<LEAVE> queue unless control flow actually
reaches the C<bail> statement.

This allows nested allocations of resources to be released in
an orderly fashion, without repeating yourself, with no deep block
nesting and with deallocation code placed next to the corresponding
allocation code.

The C<trail> statement is the same, but places the closure on the
C<LEAVE> queue as a plain <LEAVE> phaser would do (it always runs,
whether the block exits successfully or not.)  The C<trail-keep>
is probably not very useful, but is included for completeness. 
It is the same, but places the closure as the C<KEEP> phaser would
do (it runs only when the block exits successfully.)

=end DESCRIPTION

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2016 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<perl6::(1)>

use nqp;
use QAST:from<NQP>;
sub EXPORT(|) {
    my sub lk(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    role Control::Bail {
        rule statement_control:sym<bail> {
            <sym><.kok> <blorst> { 
                 # TODO We actually only need to do this for the first bail statement
                 $*W.add_phaser($/, 'LEAVE', -> { });
            }
        }
        rule statement_control:sym<trail> {
            <sym><.kok> <blorst> { 
                 # TODO We actually only need to do this for the first bail statement
                 $*W.add_phaser($/, 'LEAVE', -> { });
            }
        }
        rule statement_control:sym<trail-keep> {
            <sym><.kok> <blorst> { 
                 # TODO We actually only need to do this for the first bail statement
                 $*W.add_phaser($/, 'LEAVE', -> { });
            }
        }
    }
    role Control::Bail::Actions {
        method statement_control:sym<bail> (|c) {
            c[0].make(
                QAST::Op.new(:op<callmethod>, :name<add_phaser>,
                QAST::Op.new(:op<getcodeobj>, QAST::Op.new(:op<curcode>)),
                QAST::SVal.new(:value<UNDO>),
                lk(c[0],'blorst').ast
            ))
        }
        method statement_control:sym<trail> (|c) {
            c[0].make(
                QAST::Op.new(:op<callmethod>, :name<add_phaser>,
                QAST::Op.new(:op<getcodeobj>, QAST::Op.new(:op<curcode>)),
                QAST::SVal.new(:value<LEAVE>),
                lk(c[0],'blorst').ast
            ))
        }
        method statement_control:sym<trail-keep> (|c) {
            c[0].make(
                QAST::Op.new(:op<callmethod>, :name<add_phaser>,
                QAST::Op.new(:op<getcodeobj>, QAST::Op.new(:op<curcode>)),
                QAST::SVal.new(:value<KEEP>),
                lk(c[0],'blorst').ast
            ))
        }
    }
    nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, Control::Bail));
    nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, Control::Bail::Actions));
    {}
}
