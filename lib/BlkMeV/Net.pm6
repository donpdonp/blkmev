use v6;
use experimental :pack;
use BlkMeV;
use BlkMeV::Header;
use BlkMeV::Chain;
use BlkMeV::Command::Inv;
use BlkMeV::Command::Reject;
use BlkMeV::Command::Addr;

module BlkMeV::Net {

  our sub dispatch($socket,
                   BlkMeV::Chain::Chain $chain,
                   BlkMeV::Header::Header $header,
                   Buf $payload,
                   @mempool) {

    if $header.command eq "+connect" {
      my $msg = version($chain);
      say "sending version {$chain.protocol_version} {$chain.user_agent} block height {$chain.block_height} payload len {$msg.elems-24}";
      $socket.write($msg);
    }

    if $header.command eq "version" {
      my $v = BlkMeV::Version::Version.new;
      $v.fromBuf($payload);
      say "Connected to: {$v.user_agent} #{$v.block_height}";

      my $msg = verack($chain);
      say "send verack";
      $socket.write($msg);
    }

    if $header.command eq "verack" {
      # peer accepted us, find other peers
      $socket.write(BlkMeV::Protocol::push($chain, "getaddr", Buf.new()));
    }

    if $header.command eq "addr" {
      say "addr", $payload;
      my $c = BlkMeV::Command::Addr::Addr.new;
      $c.fromBuf($payload);
      say "Addr: count {$c.count.perl}";
    }

    if $header.command eq "reject" {
      my $c = BlkMeV::Command::Reject::Reject.new;
      $c.fromBuf($payload);
      say "Rejected: {$c.message.perl} buf {$payload.perl}";
    }

    if $header.command eq "inv" {
      my $c = BlkMeV::Command::Inv::Inv.new;
      $c.fromBuf($payload);
      for $c.vectors {
        my $hexitem = BlkMeV::Util::bufToHex($_[1]);
        say "{$c.typeName($_[0])} {$hexitem} {@mempool.elems}";
        if @mempool.index($hexitem) {
          say "Mempool dupe/found!";
        } else {
          @mempool.push($hexitem);
        }
      }
    }

    if $header.command eq "ping" {
      say "Ping/Pong {BlkMeV::Util::bufToHex($payload)}";
      $socket.write(BlkMeV::Protocol::push($chain, "pong", $payload));
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
          say "{$socket.peer-host} [{BlkMeV::Protocol::networkName($header.chain_id)}] command: {$header.command.uc} ({$header.payload_length} bytes)";
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