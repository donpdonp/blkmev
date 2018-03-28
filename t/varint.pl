use v6.c;
use Test;      # a Standard module included with Rakudo
use lib 'lib';

use BlkMeV::Protocol;

my $num-tests = 4;
plan $num-tests;

my $varStrBuf = Buf.new(1,65); # "A"
ok BlkMeV::Protocol::varStr($varStrBuf) eq "A";
nok BlkMeV::Protocol::varStr($varStrBuf) eq "B";

my $varIntBuf = Buf.new(1); # 1
ok BlkMeV::Protocol::varInt($varIntBuf) eq 1;
nok BlkMeV::Protocol::varInt($varIntBuf) eq 2;

done-testing;  # optional with 'plan'
