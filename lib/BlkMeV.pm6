use v6.c;
use Digest::SHA256::Native;
use Numeric::Pack :ints;

use BlkMeV::Protocol;
use BlkMeV::Util;

package BlkMeV {

  sub verack(BlkMeV::Chain::Chain $chain) is export {
    my $payload = Buf.new();
    BlkMeV::Protocol::push($chain, "verack", $payload);
  }

  sub getinfo is export {
    BlkMeV::Protocol::push("getinfo", Buf.new());
  }

}
