use v6;
use BlkMeV;
use BlkMeV::Header;
use BlkMeV::Chain;
use BlkMeV::Command::Inv;

module BlkMeV::Net {

  our sub dispatch($inmsg, BlkMeV::Chain::Chain $chain, $socket, $payload_tube) {
    my $payload = $payload_tube.receive;
    if $inmsg eq "connect" {
      my $msg = version($chain.protocol_version, $chain.user_agent, $chain.block_height);
      say "sending version {$chain.protocol_version} {$chain.user_agent} block height {$chain.block_height} payload len {$msg.elems-24}";
      $socket.write($msg);
    }

    if $inmsg eq "version" {
      my $v = BlkMeV::Version::Version.new;
      $v.fromBuf($payload);
      say "Connected to: {$v.user_agent} #{$v.block_height}";

      my $msg = verack;
      say "send verack";
      $socket.write($msg);
    }

    if $inmsg eq "verack" {
    }

    if $inmsg eq "inv" {
      say "Inventory msg";
      my $c = BlkMeV::Command::Inv::Inv.new;
      $c.fromBuf($payload);
      for $c.vectors {
        say "inventory type {$c.typeName($_[0])} {BlkMeV::Util::bufToHex($_[1])}";
      }
    }

    if $inmsg eq "ping" {
      say "Ping msg";
    }
  }

  our sub read_loop(IO::Socket::Async $socket, Supplier $supplier, Channel $payload_tube, Channel $master_switch) {
    my $msgbuf = Buf.new;
    my $gotHeader = False;
    my BlkMeV::Header::Header $header;
    $socket.Supply(:bin).tap( -> $buf {
      $msgbuf.append($buf);
      if !$gotHeader {
        if $msgbuf.elems >= $BlkMeV::Header::PACKET_LENGTH {
          my $header_buf = BlkMeV::Util::bufTrim($msgbuf, $BlkMeV::Header::PACKET_LENGTH);
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
    },
    done => ->  { say "async IO done"; $master_switch.send(0) } ,
    quit => ->  { say "async IO quit" });
  }

}