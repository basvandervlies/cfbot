#!/usr/bin/env perl

=pod

=head1 SYNOPSIS

Test cfbot bug lookup and feed functions

=cut

use strict;
use warnings;
use Test::More tests => 4;
require cfbot;

my $config = cfbot::_load_config( 'cfbot.yml' );

_test_bug_exists( 2333 );

_test_bug_not_found( 999999 );

_test_bug_number_invalid( 'xxxxx' );

_test_cfengine_bug_atom_feed({
   feed       => $config->{bug_feed},
   newer_than => 2880
});

#
# Subs
#

# Test that get_bug sub returns a bug entry.
sub _test_bug_exists {
   my $bug = shift;
   my $msg = cfbot::get_bug( $bug );

   subtest 'Lookup existing bug' => sub {
      ok( $msg->[0] =~ m|\A$config->{bug_tracker}/$bug|, "URL correct?" );
      ok( $msg->[0] =~ m|Variables not expanded inside array\Z|, "Subject correct?" );
   };
   return;
}

# Test that get_bug sub handle an unkown bug properly.
sub _test_bug_not_found {
   my $bug = shift;
   my $msg = cfbot::get_bug( $bug );
   is( $msg->[0], "Bug [$bug] not found", "Bug not found" );
   return;
}

# Test that get_bug sub handles an invalid bug number.
sub _test_bug_number_invalid {
   my $bug = shift;
   my $msg = cfbot::get_bug( $bug );
   is( $msg->[0], "[$bug] is not a valid bug number", "Bug number invalid" );
   return;
}

# Test that bug feed returns at least one correct entry.
sub _test_cfengine_bug_atom_feed {
   my ( $arg ) = @_;

   my $events = cfbot::atom_feed({
      feed       => $arg->{feed},
      newer_than => $arg->{newer_than}
   });

   # e.g. Feature #7346 (Open): string_replace function
   ok( $events->[0] =~ m/\A(Documentation|Cleanup|Bug|Feature) #\d{4,5}.+\Z/i,
      "Was a bug returned?" );
   return;
}

