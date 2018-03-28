use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV::Command::Reject {
  class Reject {
    has Str $.message;

    method fromBuf(Buf $b) {
      $!message = BlkMeV::Protocol::varStr($b);
    }
  }
}
