use BlkMeV::Chain::Params::Params;
use Digest::SHA256::Native;

package BlkMeV::Chain::Params {
  class BitcoinCash is Params {
    method new {
      my $name = "bitcoincash";
      my $header = Buf.new(0xe3, 0xe1, 0xf3, 0xe8);
      my $host = "seed.bitcoinabc.org";
      my $port = 8333;
      my $services = 7;
      my &hash_func = &sha256;
      my $protocol_version = 70015;  #bitcoincash 0.7.1
      my $block_height = 500000;

      return self.bless(:$name, :$header, :$host, :$port, :&hash_func,
                        :user_agent("BlkMev:{$name}"), :$services,
                        :$protocol_version, :$block_height);
    }
  }
}