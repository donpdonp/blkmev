use BlkMeV::Util;
use BlkMeV::Chain::Params::Bitcoin;
#use BlkMeV::Chain::BitcoinCash;
#use BlkMeV::Chain::Dogecoin;
#use BlkMeV::Chain::Litecoin;
use Digest::SHA256::Native;

package BlkMeV::Chain {
  #my @list = ["Bitcoin", "BitcoinCash", "Litecoin", "Dogecoin"];
  my @coin_params = [BlkMeV::Chain::Params::Bitcoin.new];

  our sub chain_params_by_name($name) {
    @coin_params.first(-> $params { $name eq $params.name });
  }

  our sub chain_params_by_header($header) {
    @coin_params.first(-> $params { $header cmp $params.header == Same });
  }

  class Chain {
    has $.params;

    method new(str :$name) {
      my $params = chain_params_by_name($name);

      return self.bless(:$params);
    }

#      if $name eq BlkMeV::Chain::BitcoinCash::<$name> {
#        $host = "seed-abc.bitcoinforks.org";
#        $port = 8333;
#        &hash_func = &sha256;
#        $protocol_version = 70015;  #bitcoincash 0.7.1
#        $block_height = 500000;
#      }

#      if $name eq "dogecoin" {
#        $host = "seed.multidoge.org";
#        $port = 22556;
#        &hash_func = &sha256;
#        $protocol_version = 1100004;  #dogecoin 1.10.0
#        $block_height = 2150000;
#      }

#      if $name eq "litecoin" {
#        $host = "dnsseed.litecoinpool.org";
#        $port = 9333;
#        &hash_func = &sha256;
#        $protocol_version = 150000;  #litecoin 0.15.0
#        $block_height = 1392000;
#      }
  }

}
