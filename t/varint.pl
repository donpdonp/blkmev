use v6.c;
use Test;      # a Standard module included with Rakudo
use lib 'lib';

use BlkMeV::Protocol;

my $num-tests = 1;
plan $num-tests;

# .... tests
ok BlkMeV::Protocol::varStr(Buf.new(1,65)) eq "A";
nok BlkMeV::Protocol::varStr(Buf.new(1,65)) eq "B";

done-testing;  # optional with 'plan'
