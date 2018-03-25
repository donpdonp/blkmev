use Numeric::Pack :ints;
use experimental :pack;

module BlkMeV::Util {

our sub bufToInt32($buf) {
  #unpack-uint32 $buf.subbuf(16,4), :byte-order(little-endian);
  $buf.unpack("L");
}

}
