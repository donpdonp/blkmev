use Digest::SHA256::Native;
use BlkMeV::Util;

module BlkMeV::Protocol {

our sub push($verb, $payload) {
  my $hello = Buf.new(0xf9, 0xbe, 0xb4, 0xd9); # Bitcoin Mainnet
  my $command = BlkMeV::Util::strPad($verb);
  my $payload_length = BlkMeV::Util::int32Buf($payload.elems);

  my $payload_checksum = sha256(sha256($payload)).subbuf(0,4);

  my $msg = Buf.new();
  $msg.append($hello);
  $msg.append($command);
  $msg.append($payload_length);
  $msg.append($payload_checksum);
  $msg.append($payload);
}

}