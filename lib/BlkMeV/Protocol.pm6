use Digest::SHA256::Native;
use BlkMeV::Util;

module BlkMeV::Protocol {

  our sub push($verb, $payload) {
    my $hello = Buf.new(0xf9, 0xbe, 0xb4, 0xd9); # Bitcoin Mainnet
    my $command = BlkMeV::Util::strZeroPad($verb, 12);
    my $payload_length = BlkMeV::Util::int32Buf($payload.elems);

    my $payload_checksum = sha256(sha256($payload)).subbuf(0,4);

    my $msg = Buf.new();
    $msg.append($hello);
    $msg.append($command);
    $msg.append($payload_length);
    $msg.append($payload_checksum);
    $msg.append($payload);
  }

  our sub networkName(Buf $id) {
    given $id {
      when $_ cmp Buf.new(0xf9, 0xbe, 0xb4, 0xd9) == Same { "Bitcoin" };
      when $_ cmp Buf.new(0xfb, 0xc0, 0xb6, 0xdb) == Same { "Litecoin" };
      when $_ cmp Buf.new(0xfc, 0xc1, 0xb7, 0xdc) == Same { "Dogecoin" };
    }
  }

  our sub netAddress($addr) {
    Buf.new(0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,
            0x0a, 0x00, 0x00, $addr, 0x20, 0x8D)
  }

}