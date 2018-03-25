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
    if $s.chars < 255 {
      $buf.append($s.chars);
      $buf.append($s.encode('ascii'));
    } else {
      say "WARNING: strings > 255 are unimplemented";
    }
    $buf;
  }

  our sub strZeroPad(Str $s, Int $padlen) {
    Buf.new($s.encode('ISO-8859-1')).reallocate($padlen);
  }

  our sub bufToInt32($buf) {
    #unpack-uint32 $buf.subbuf(16,4), :byte-order(little-endian);
    $buf.unpack("L");
  }

  our sub bufTrim($msgbuf, $payload_len) {
    my $payload = $msgbuf.subbuf(0, $payload_len);
    subbuf-rw($msgbuf, 0, $payload_len) = Buf.new;
    $payload
  }

  our sub bufToStr($buf) {
    join "", $buf.map: { last when 0; $_.chr  }
  }

}
