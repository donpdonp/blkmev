use BlkMeV::Chain::Params::Params;
use Digest::SHA256::Native;

package BlkMeV::Chain::Params {
  class Litecoin is Params {
    method new {
      my $name = "litecoin";
      my $header = Buf.new(0xfb, 0xc0, 0xb6, 0xdb );
      my $host = "dnsseed.litecoinpool.org";
      my $port = 9333;
      my $services = 7;
      my &hash_func = &sha256;
      my $protocol_version = 150000;  #litecoin 0.15.0
      my $block_height = 1392000;

      return self.bless(:$name, :$header, :$host, :$port, :&hash_func,
                        :user_agent("BlkMev:{$name}"), :$services,
                        :$protocol_version, :$block_height);
    }
  }
}