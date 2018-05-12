use v6.c;
use Test;      # a Standard module included with Rakudo
use lib 'lib';

use BlkMeV::Protocol;

my $num-tests = 5;
plan $num-tests;

my $varStrBuf = Buf.new(1,65); # "A"
ok BlkMeV::Protocol::varStr($varStrBuf) eq "A";
nok BlkMeV::Protocol::varStr($varStrBuf) eq "B";

my $varIntBuf = Buf.new(1); # 1
ok BlkMeV::Protocol::varInt($varIntBuf) eq 1;
nok BlkMeV::Protocol::varInt($varIntBuf) eq 2;

my $varIntBuf = Buf.new(0xfd, 0x01, 0x01);
ok BlkMeV::Protocol::varInt($varIntBuf) eq 257;

done-testing;  # optional with 'plan'
