use Numeric::Pack :ints;
use experimental :pack;

module BlkMeV::Util {

  our sub int32Buf($int) {
    pack-uint32 $int, :byte-order(little-endian);;
  }

  our sub int64Buf($int) {
    pack-uint64 $int, :byte-order(little-endian);;
  }

  our sub strToBuf($s) {
    my $buf = Buf.new();
    $buf.append($s.chars);
    $buf.append($s.encode('ascii'));
    $buf;
  }

  our sub strPad(Str $s) {
    Buf.new($s.encode('ISO-8859-1')).reallocate(12);
  }

  our sub bufToInt32($buf) {
    #unpack-uint32 $buf.subbuf(16,4), :byte-order(little-endian);
    $buf.unpack("L");
  }

}
