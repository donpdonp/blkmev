use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV::Command::Addr {
  class Addr {
    has Int $.count;

    method fromBuf(Buf $b) {
      my $intlen = BlkMeV::Protocol::varIntByteCount($b);
      $!count = BlkMeV::Protocol::varInt($b);
      my $addrsize = 30;
      for 0..^$!count -> $idx {
        my $offset = $intlen + ($idx * $addrsize);
        my $date = $b.subbuf($offset, 4);
        my $services = $b.subbuf($offset+4, 8);
        my $addr = $b.subbuf($offset+12, 16);
        my $port = BlkMeV::Util::bufToInt16($b.subbuf($offset+28, 2));
        say "addr.frombuf {$addr.perl} port {$port}";
      }
    }
  }
}
