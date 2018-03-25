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

  our sub decodeHeader(Buf $buf) {
    my $command = BlkMeV::Util::bufToStr($buf.subbuf(4,12));
    my $rlen = BlkMeV::Util::bufToInt32($buf.subbuf(16,4));
    say "chain: {networkName($buf.subbuf(0,4))} Received: {$command.uc} ({$rlen} bytes)";
    [$command, $rlen]
  }

  our sub networkName(Buf $id) {
    "Bitcoin" if $id == Buf.new(0xf9, 0xbe, 0xb4, 0xd9);
  }

  our sub netAddress($addr) {
    Buf.new(0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,
            0x0a, 0x00, 0x00, $addr, 0x20, 0x8D)
  }

}