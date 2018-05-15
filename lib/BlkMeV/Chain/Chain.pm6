use BlkMeV::Util;
use BlkMeV::Chain::Params::Bitcoin;
use BlkMeV::Chain::Params::BitcoinCash;
use BlkMeV::Chain::Params::Dogecoin;
use BlkMeV::Chain::Params::Litecoin;
use Digest::SHA256::Native;

package BlkMeV::Chain {
  my @coin_params = [BlkMeV::Chain::Params::Bitcoin.new,
                     BlkMeV::Chain::Params::BitcoinCash.new,
                     BlkMeV::Chain::Params::Dogecoin.new,
                     BlkMeV::Chain::Params::Litecoin.new];

  our sub chain_params_by_name(Str $name) {
    @coin_params.first(-> $params { $name eq $params.name });
  }

  our sub chain_params_by_header(Buf $header) {
    @coin_params.first(-> $params { $header cmp $params.header == Same });
  }

  class Chain {
    has $.params;

    method new(str :$name) {
      my $params = chain_params_by_name($name);

      return self.bless(:$params);
    }
  }
}
