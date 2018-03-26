use BlkMeV::Util;

module BlkMeV::Header {
  our $PACKET_LENGTH = 24;

  class Header {
    has Buf $.chain_id;
    has Str $.command;
    has Int $.payload_length;

    method fromBuf(Buf $buf) {
      $!chain_id = $buf.subbuf(0,4);
      $!command = BlkMeV::Util::bufToStr($buf.subbuf(4,12));
      $!payload_length = BlkMeV::Util::bufToInt32($buf.subbuf(16,4));
    }
  }
}
