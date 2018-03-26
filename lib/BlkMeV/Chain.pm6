use BlkMeV::Util;
use Digest::SHA256::Native;

module BlkMeV::Chain {
  class Chain {
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

      if $name eq "bitcoin" {
        $host = "seed.bitcoin.sipa.be";
        $port = 8333;
        &hash_func = &sha256;
        $protocol_version = 100004;  #bitcoin 0.10.0
        $block_height = 500000;
      }

      if $name eq "dogecoin" {
        $host = "doger.dogecoin.com";
        $port = 22556;
        &hash_func = &sha256;
        $protocol_version = 100004;  #bitcoin 0.10.0
        $block_height = 1200000;
      }

      return self.bless(:$host, :$port, :&hash_func, user_agent => "/BlkMeV:0.1.0/",
                        :$protocol_version, :$block_height);
    }
  }
}
