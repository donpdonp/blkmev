use BlkMeV::Chain::Params::Params;
use Digest::SHA256::Native;

package BlkMeV::Chain::Params {
  class Dogecoin is Params {
   method new {
      my $name = "dogecoin";
      my $header = Buf.new(0xc0, 0xc0, 0xc0, 0xc0);
      my $host = "seed.multidoge.org";
      my $port = 22556;
      my &hash_func = &sha256;
      my $protocol_version = 1100004;  #dogecoin 1.10.0
      my $block_height = 2150000;

      return self.bless(:$name, :$header, :$host, :$port, :&hash_func,
                        :user_agent("BlkMev:{$name}"),
                        :$protocol_version, :$block_height);
    }
  }
}