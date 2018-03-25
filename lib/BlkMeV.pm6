use v6.c;
use Digest::SHA256::Native;
use Numeric::Pack :ints;

use BlkMeV::Version;
use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV {

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
  $payload.append(BlkMeV::Protocol::netAddress(1)); #Recipient
  $payload.append(BlkMeV::Protocol::netAddress(2)); #Sender
  $payload.append(BlkMeV::Util::int64Buf(1521609933)); #nodeID/nonce
  $payload.append(BlkMeV::Util::strToBuf($user_agent)); #client version string
  $payload.append(BlkMeV::Util::int32Buf($blockheight)); #blockheight
  BlkMeV::Protocol::push("version", $payload);
}

sub getinfo is export {
  BlkMeV::Protocol::push("getinfo", Buf.new());
}

}
