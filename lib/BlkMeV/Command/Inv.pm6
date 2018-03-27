use BlkMeV::Util;
use BlkMeV::Protocol;

module BlkMeV::Command::Inv {
  class Inv {
    has Int $.count;
    has Array $.vectors = [];

    method fromBuf(Buf $b) {
      $!count = BlkMeV::Protocol::varInt($b);
      my $len_count = BlkMeV::Protocol::varIntByteCount($b);
      say "Inv count {$!count} (using storage {$len_count})";
      for 0..($!count-1) -> $idx {
        my $item_size = 36;
        my $item_offset = $len_count + ($idx * $item_size);
        my $item = $b.subbuf($item_offset, $item_size);
        my $type = BlkMeV::Util::bufToInt32($item);
        my $hash = $b.subbuf($item_offset+4, 32);
        @.vectors.push(($type, $hash));
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
