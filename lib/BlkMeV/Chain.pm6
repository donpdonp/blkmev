use BlkMeV::Util;
use BlkMeV::Chain::Bitcoin;
use BlkMeV::Chain::BitcoinCash;
use BlkMeV::Chain::Dogecoin;
use BlkMeV::Chain::Litecoin;
use Digest::SHA256::Native;

module BlkMeV::Chain {
  class Chain {
    has Str $.name;
    has Str $.host;
    has Int $.port;
    has &.hash_func;
    has Str $.user_agent;
    has Int $.protocol_version;
    has Int $.block_height;

    method new(str :$name) {
      my $host;
      my $port;
      my &hash_func;
      my $protocol_version;
      my $block_height;

      if $name eq BlkMeV::Chain::Bitcoin::<$name> {
        $host = "seed.bitcoin.sipa.be";
        $port = 8333;
        &hash_func = &sha256;
        $protocol_version = 100004;  #bitcoin 0.10.0
        $block_height = 500000;
      }

      if $name eq BlkMeV::Chain::BitcoinCash::<$name> {
        $host = "seed-abc.bitcoinforks.org";
        $port = 8333;
        &hash_func = &sha256;
        $protocol_version = 70015;  #bitcoincash 0.7.1
        $block_height = 500000;
      }

      if $name eq "dogecoin" {
        $host = "seed.multidoge.org";
        $port = 22556;
        &hash_func = &sha256;
        $protocol_version = 1100004;  #dogecoin 1.10.0
        $block_height = 2150000;
      }

      if $name eq "litecoin" {
        $host = "dnsseed.litecoinpool.org";
        $port = 9333;
        &hash_func = &sha256;
        $protocol_version = 150000;  #litecoin 0.15.0
        $block_height = 1392000;
      }

      return self.bless(:$name, :$host, :$port, :&hash_func, user_agent => "/BlkMeV:0.1.0/",
                        :$protocol_version, :$block_height);
    }
  }
}
