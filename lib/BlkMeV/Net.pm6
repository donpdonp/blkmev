use v6;
use BlkMeV;
use BlkMeV::Header;

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
#    say "send getinfo";
#    $socket.write($msg);
  }
}

our sub read_loop(IO::Socket::Async $socket, Supplier $supplier, Channel $payload_tube) {
  my $msgbuf = Buf.new;
  my $gotHeader = False;
  my BlkMeV::Header::Header $header;
  $socket.Supply(:bin).tap( -> $buf {
    $msgbuf.append($buf);
    if !$gotHeader {
      if $msgbuf.elems >= 24 {
        my $header_buf = BlkMeV::Util::bufTrim($msgbuf, 24);
        $header = BlkMeV::Header::Header.new;
        $header.fromBuf($header_buf);
        $gotHeader = True;
        say "chain: {BlkMeV::Protocol::networkName($header.chain_id)} Received: {$header.command.uc} ({$header.payload_length} bytes)";
      }
    }

    if $msgbuf.elems >= $header.payload_length {
      my $payload = BlkMeV::Util::bufTrim($msgbuf, $header.payload_length);
      $gotHeader = False;
      #payload processing
      $payload_tube.send($payload);
      $supplier.emit($header.command);
    }
  });
}

}