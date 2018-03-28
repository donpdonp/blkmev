use v6.c;
use Digest::SHA256::Native;
use Numeric::Pack :ints;

use BlkMeV::Protocol;
use BlkMeV::Util;
use BlkMeV::Version;

module BlkMeV {

  sub verack(BlkMeV::Chain::Chain $chain) is export {
    my $payload = Buf.new();
    BlkMeV::Protocol::push($chain, "verack", $payload);
  }

  sub version(BlkMeV::Chain::Chain $chain) is export {
    my $payload = Buf.new();
    $payload.append(BlkMeV::Util::int32Buf($chain.protocol_version)); #version
    $payload.append(BlkMeV::Util::int64Buf(7)); #services
    $payload.append(BlkMeV::Util::int64Buf(DateTime.now.posix)); #timestamp
    $payload.append(BlkMeV::Protocol::netAddress(1)); #Recipient
    $payload.append(BlkMeV::Protocol::netAddress(2)); #Sender
    $payload.append(BlkMeV::Util::int64Buf(1521609933)); #nodeID/nonce
    $payload.append(BlkMeV::Util::strToBuf($chain.user_agent)); #client version string
    $payload.append(BlkMeV::Util::int32Buf($chain.block_height)); #blockheight
    BlkMeV::Protocol::push($chain, "version", $payload);
  }

  sub getinfo is export {
    BlkMeV::Protocol::push("getinfo", Buf.new());
  }

}
