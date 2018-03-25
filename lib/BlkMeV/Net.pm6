use v6;
use BlkMeV;

module BlkMeV::Net {

our sub dispatch($inmsg, $socket, $payload_tube) {
  if $inmsg eq "connect" {
    my $protoversion = 100004; #bitcoin 0.10.0
    my $useragent = "/BlkMeV:0.1.0/";
    my $msg = version($protoversion, $useragent, 500000);
    say "send version {$protoversion} {$useragent} payload {$msg.elems-24}";
    $socket.write($msg);
  }

  if $inmsg eq "version" {
    my $payload = $payload_tube.receive;
    my $v = BlkMeV::Version::Version.new;
    $v.fromBuf($payload);
    say "Connected to: {$v.user_agent} #{$v.block_height}";

    my $msg = verack;
    say "send verack";
    $socket.write($msg);
  }

  if $inmsg eq "verack" {
    my $msg = getinfo;
    say "send getinfo";
    $socket.write($msg);
  }
}

our sub read_loop(IO::Socket::Async $socket, Supplier $supplier, Channel $payload_tube) {
  my $msgbuf = Buf.new;
  my $gotHeader = False;
  my $verb = "";
  my $payload_len = 0;
  $socket.Supply(:bin).tap( -> $buf {
    $msgbuf.append($buf);
    if !$gotHeader {
      if $msgbuf.elems >= 24 {
        my $header = BlkMeV::Util::bufTrim($msgbuf, 24);
        my @header = BlkMeV::Protocol::decodeHeader($header);
        $verb = @header[0];
        $payload_len = @header[1];
        $gotHeader = True;
      }
    }
    if $msgbuf.elems >= $payload_len {
      my $payload = BlkMeV::Util::bufTrim($msgbuf, $payload_len);
      $gotHeader = False;
      #payload processing
      $payload_tube.send($payload);
      $supplier.emit($verb);
    }
  });
}

}