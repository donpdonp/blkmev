use v6.c;
use Test;      # a Standard module included with Rakudo
use lib 'lib';

use BlkMeV::Protocol;

my $num-tests = 5;
plan $num-tests;

my Buf $buf;

$buf = Buf.new(1,65); # "A"
ok BlkMeV::Protocol::varStr($buf) eq "A";
nok BlkMeV::Protocol::varStr($buf) eq "B";

$buf = Buf.new(1); # 1
ok BlkMeV::Protocol::varInt($buf) eq 1;
nok BlkMeV::Protocol::varInt($buf) eq 2;

$buf = Buf.new(0xfd, 0x01, 0x01);
ok BlkMeV::Protocol::varInt($buf) eq 257;

done-testing;  # optional with 'plan'
