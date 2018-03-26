use BlkMeV::Util;
use Digest::SHA256::Native;

module BlkMeV::Chain {
  class Chain {
    has Str $.host;
    has Int $.port;
    has &.hash_func;

    method new(str :$name) {
      my $host;
      my $port;
      my &hash_func;

      if $name eq "bitcoin" {
        $host = "seed.bitcoin.sipa.be";
        $port = 8333;
        &hash_func = &sha256;
      }

      if $name eq "dogecoin" {
        $host = "doger.dogecoin.com";
        $port = 22556;
        &hash_func = &sha256;
      }

      return self.bless(:$host, :$port, :&hash_func);
    }
  }
}
