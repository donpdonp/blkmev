use v6;
use BlkMeV;
use BlkMeV::Header;
use BlkMeV::Chain;
use BlkMeV::Command::Inv;

module BlkMeV::Net {

  our sub dispatch($socket,
                   BlkMeV::Chain::Chain $chain,
                   BlkMeV::Header::Header $header,
                   Buf $payload) {
    if $header.command eq "+connect" {
      my $msg = version($chain.protocol_version, $chain.user_agent, $chain.block_height);
      say "sending version {$chain.protocol_version} {$chain.user_agent} block height {$chain.block_height} payload len {$msg.elems-24}";
      $socket.write($msg);
    }

    if $header.command eq "version" {
      my $v = BlkMeV::Version::Version.new;
      $v.fromBuf($payload);
      say "Connected to: {$v.user_agent} #{$v.block_height}";

      my $msg = verack;
      say "send verack";
      $socket.write($msg);
    }

    if $header.command eq "verack" {
    }

    if $header.command eq "inv" {
      my $c = BlkMeV::Command::Inv::Inv.new;
      $c.fromBuf($payload);
      for $c.vectors {
        say "inventory type {$c.typeName($_[0])} {BlkMeV::Util::bufToHex($_[1])}";
      }
    }

    if $header.command eq "ping" {
      say "Ping/Pong {BlkMeV::Util::bufToHex($payload)}";
      $socket.write(BlkMeV::Protocol::push("pong", $payload));
    }
  }

  our sub read_loop(IO::Socket::Async $socket, $chain, Supplier $supplier, Channel $master_switch) {
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
        $supplier.emit(($socket, $chain, $header, $payload));
      }
    },
    done => ->  { say "async IO done"; $master_switch.send(0) } ,
    quit => ->  { say "async IO quit" });
  }

}