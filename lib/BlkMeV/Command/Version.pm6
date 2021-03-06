use BlkMeV::Util;
use BlkMeV::Chain::Chain;

package BlkMeV {
  module Command is export {
    class Version {
      has Str $.addr_recv;
      has Str $.addr_from;
      has Str $.user_agent;
      has Int $.block_height;
      has Int $.protocol_version;

      method build(BlkMeV::Chain::Chain $chain) {
        my $payload = Buf.new();
        $payload.append(Util::int32Buf($chain.params.protocol_version)); #version
        $payload.append(Util::int64Buf($chain.params.services)); #services
        $payload.append(Util::int64Buf(DateTime.now.posix)); #timestamp
        $payload.append(BlkMeV::Protocol::netAddress(1)); #Recipient
        $payload.append(BlkMeV::Protocol::netAddress(2)); #Sender
        $payload.append(Util::int64Buf(1521609933)); #nodeID/nonce
        $payload.append(Util::strToBuf($chain.params.user_agent)); #client version string
        $payload.append(Util::int32Buf($chain.params.block_height)); #blockheight
      }

      method fromBuf(Buf $b) {
        my $protocol_version_buf = $b.subbuf(0, 4);
        $!protocol_version = Util::bufToInt32($protocol_version_buf);
        $!addr_recv = $b.subbuf(20, 26).perl;
        $!addr_from = $b.subbuf(46, 26).perl;
        my $strlen = $b[80];
        $!user_agent = Util::bufToStr($b.subbuf(81, $strlen));
        my $block_height_buf = $b.subbuf(81+$strlen, 4);
        $!block_height = Util::bufToInt32($block_height_buf)
      }
    }
  }
}
