use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV::Command::Reject {
  class Reject {
    has Str $.code;
    has Str $.message;

    method fromBuf(Buf $buf) {
      $!code = BlkMeV::Protocol::varStr($buf);
      my $countlen = BlkMeV::Protocol::varIntByteCount($buf);
      my $count = BlkMeV::Protocol::varInt($buf);
      $!message = BlkMeV::Protocol::varStr($buf.subbuf($countlen + $count + 1, $buf.elems));
    }
  }
}
