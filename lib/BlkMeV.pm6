use v6.c;
use Digest::SHA256::Native;
use Numeric::Pack :ints;

use BlkMeV::Version;
use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV {

sub netAddress($addr) {
  Buf.new(0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,
          0x0a, 0x00, 0x00, $addr, 0x20, 0x8D)
}

our sub decodeVersion($b) {
  my $v = BlkMev::version::Version.new;
  $v.fromBuf($b);
  $v
}

sub verack is export {
  my $payload = Buf.new();
  BlkMeV::Protocol::push("verack", $payload);
}

sub version($version, $user_agent, $blockheight) is export {
  my $payload = Buf.new();
  $payload.append(BlkMeV::Util::int32Buf($version)); #version
  $payload.append(BlkMeV::Util::int64Buf(7)); #services
  $payload.append(BlkMeV::Util::int64Buf(DateTime.now.posix)); #timestamp
  $payload.append(netAddress(1)); #Recipient
  $payload.append(netAddress(2)); #Sender
  $payload.append(BlkMeV::Util::int64Buf(1521609933)); #nodeID/nonce
  $payload.append(BlkMeV::Util::strToBuf($user_agent)); #client version string
  $payload.append(BlkMeV::Util::int32Buf($blockheight)); #blockheight
  BlkMeV::Protocol::push("version", $payload);
}

sub getinfo is export {
  BlkMeV::Protocol::push("getinfo", Buf.new());
}

sub networkName(Buf $id) {
  "Bitcoin" if $id == Buf.new(0xf9, 0xbe, 0xb4, 0xd9);
}

our sub bufToStr($buf) {
  join "", $buf.map: { last when 0; $_.chr  }
}

our sub decodeHeader(Buf $buf) {
  my $command = bufToStr($buf.subbuf(4,12));
  my $rlen = BlkMeV::Util::bufToInt32($buf.subbuf(16,4));
  say "chain: {networkName($buf.subbuf(0,4))} Received: {$command.uc} ({$rlen} bytes)";
  [$command, $rlen]
}

}
