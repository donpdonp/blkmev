use Digest::SHA256::Native;
use BlkMeV::Util;
use BlkMeV::Chain;
use BlkMeV::Chain::Bitcoin;
use BlkMeV::Chain::Litecoin;
use BlkMeV::Chain::Dogecoin;

module BlkMeV::Protocol {
  our sub push(BlkMeV::Chain::Chain $chain, $verb, $payload) {
    my $hello = networkHello($chain.name); # Bitcoin Mainnet
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

  our sub networkHello(Str $name) {
    given $name {
      when BlkMeV::Chain::Bitcoin::<$name> { BlkMeV::Chain::Bitcoin::<$header> }
      when BlkMeV::Chain::Litecoin::<$name> { BlkMeV::Chain::Litecoin::<$header> }
      when BlkMeV::Chain::Dogecoin::<$name> { BlkMeV::Chain::Dogecoin::<$header> }
    }
  }

  our sub networkName(Buf $id) {
    given $id {
      when $_ cmp BlkMeV::Chain::Bitcoin::<$header> == Same { BlkMeV::Chain::Bitcoin::<$name> };
      when $_ cmp BlkMeV::Chain::Litecoin::<$header> == Same { BlkMeV::Chain::Litecoin::<$name> };
      when $_ cmp BlkMeV::Chain::Dogecoin::<$header> == Same { BlkMeV::Chain::Dogecoin::<$name> };
    }
  }

  our sub netAddress($addr) {
    Buf.new(0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,
            0x0a, 0x00, 0x00, $addr, 0x20, 0x8D)
  }

  our sub bufToAddress(Buf $b) {
    my $v4 = $b[10] == 0xff && $b[11] == 0xff;
    if $v4 { "{$b[12]}.{$b[13]}.{$b[14]}.{$b[15]}" } else {"ipv6"}
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