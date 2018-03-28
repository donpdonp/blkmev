use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV::Command::Addr {
  class Addr {
    has Int $.count;

    method fromBuf(Buf $b) {
      $!count = BlkMeV::Protocol::varInt($b);
    }
  }
}
