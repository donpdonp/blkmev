use v6.c;
use Test;
use lib 'lib';

use BlkMeV::Util;

plan 7;

my Buf $buf;
my Int $int;

ok 1 eq Util::bufToInt16(Buf.new(1,0));
ok 256 eq Util::bufToInt16(Buf.new(0,1));

$buf = Util::int32Buf(1);
ok Buf.new(1,0,0,0) eq $buf;
$int = Util::bufToInt32($buf);
ok 1 eq $int;

$buf = Util::int32Buf(2**24);
ok Buf.new(0,0,0,1) eq $buf;

$buf = Util::int64Buf(1);
ok Buf.new(1,0,0,0,0,0,0,0) eq $buf;

$buf = Util::int64Buf(2**56);
ok Buf.new(0,0,0,0,0,0,0,1) eq $buf;

done-testing;  # optional with 'plan'
