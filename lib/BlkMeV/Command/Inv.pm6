use BlkMeV::Util;
use BlkMeV::Primitives;
use BlkMeV::Protocol;

module BlkMeV::Command::Inv {
  class Inv {
    has Int $.count;
    has Array $.vectors = [];

    method fromBuf(Buf $b) {
      $!count = BlkMeV::Protocol::varInt($b);
      my $len_count = BlkMeV::Protocol::varIntByteCount($b);
      for 0..($!count-1) -> $idx {
        my $item_size = 36;
        my $item_offset = $len_count + ($idx * $item_size);
        my $item = $b.subbuf($item_offset, $item_size);
        my $typecode = BlkMeV::Util::bufToInt32($item);
        my $hash = $b.subbuf($item_offset+4, 32);
        my $tx = Primitives::Transaction.new(:$typecode, :$hash);
        @.vectors.push($tx);
      }
    }

    method typeName(Int $t) {
      given $t {
        when 0 { "ERROR" }
        when 1 { "TX" }
        when 2 { "BLOCK" }
      }
    }
  }
}
