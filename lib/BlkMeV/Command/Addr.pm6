use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV::Command::Addr {
  class Addr {
    has Int $.count;
    has @.addrs;

    method fromBuf(Buf $b) {
      my $intlen = BlkMeV::Protocol::varIntByteCount($b);
      $!count = BlkMeV::Protocol::varInt($b);
      my $addrsize = 30;
      for 0..^$!count -> $idx {
        my $offset = $intlen + ($idx * $addrsize);
        my $date = BlkMeV::Util::bufToInt32($b.subbuf($offset, 4));
        my $services = $b.subbuf($offset+4, 8);
        my $addr = BlkMeV::Protocol::bufToAddress($b.subbuf($offset+12, 16));
        my $port = BlkMeV::Util::bufToInt16BE($b.subbuf($offset+28, 2));
        @!addrs.push(($addr, $port));
      }
    }
  }
}
