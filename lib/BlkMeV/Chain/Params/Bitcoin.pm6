use BlkMeV::Chain::Params::Params;
use Digest::SHA256::Native;

package BlkMeV::Chain::Params {
  class Bitcoin is BlkMeV::Chain::Params::Params {
    method new {
      my $name = "bitcoin";
      my $header = Buf.new(0xf9, 0xbe, 0xb4, 0xd9);
      my $host = "seed.bitcoin.sipa.be";
      my $port = 8333;
      my &hash_func = &sha256;
      my $protocol_version = 100004;  #bitcoin 0.10.0
      my $block_height = 500000;

      return self.bless(:$name, :$header, :$host, :$port, :&hash_func,
                        :user_agent("BlkMev:{$name}"),
                        :$protocol_version, :$block_height);
    }
  }
}