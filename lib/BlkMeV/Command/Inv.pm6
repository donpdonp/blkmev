use BlkMeV::Util;

module BlkMeV::Command::Inv {
  class Inv {
    has Int $.count;

    method fromBuf(Buf $b) {
      say "Inv", $b;
    }
  }
}
