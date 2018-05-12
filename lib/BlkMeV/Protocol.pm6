use Digest::SHA256::Native;
use BlkMeV::Util;
use BlkMeV::Chain::Chain;

module BlkMeV::Protocol {
  our sub push(BlkMeV::Chain::Chain $chain, $verb, $payload) {
    my $hello = $chain.params.header; say $hello.perl;
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

  our sub netAddress($addr) {
    Buf.new(0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,
            0x0a, 0x00, 0x00, $addr, 0x20, 0x8D)
  }

  our sub bufToAddress(Buf $b) {
    my $v4 = $b[10] == 0xff && $b[11] == 0xff;
    if $v4 { "{$b[12]}.{$b[13]}.{$b[14]}.{$b[15]}" }
      else { "[{($b.map(-> $d { Buf.new($d).unpack("H") }).join(":"))}]" }
  }

  our sub varIntByteCount($buf) returns Int {
    if $buf[0] < 0xfd { return 1 }
    if $buf[0] == 0xfd { return 3 }
    if $buf[0] == 0xfe { return 5 }
    if $buf[0] == 0xff { return 9 }
  }

  our sub varInt($buf) returns Int {
    my $len = varIntByteCount($buf) - 1;
    if $len == 0 {
      return $buf[0];
    }
    if $len == 2 {
      return BlkMeV::Util::bufToInt16($buf.subbuf(1,$len))
    }
    if $len == 4 {
      return BlkMeV::Util::bufToInt32($buf.subbuf(1,$len))
    }
  }

  our sub varStr($buf) {
    my $len = varIntByteCount($buf);
    my $count = varInt($buf);
    BlkMeV::Util::bufToAscii($buf.subbuf($len, $count));
  }
}