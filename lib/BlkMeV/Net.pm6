use v6;
use experimental :pack;
use BlkMeV;
use BlkMeV::Header;
use BlkMeV::Chain;
use BlkMeV::Protocol;
use BlkMeV::Command::Inv;
use BlkMeV::Command::Reject;
use BlkMeV::Command::Addr;
use BlkMeV::Command::Version;

package BlkMeV {
  module Net is export {

    our sub client (@mempool, $chain, $host, $master_switch) {
      my $supplier = Supplier.new;
      my $supply = $supplier.Supply;

      say "* connecting {$chain.name} {$host}:{$chain.port}";

      IO::Socket::Async.connect($host, $chain.port).then( -> $promise {
        CATCH { default { say .^name, ': ', .Str } };
        my $socket = $promise.result;
        say "connected to {$socket.peer-host}:{$socket.peer-port}";
        my $header = BlkMeV::Header::Header.new;
        $header.fromStr("+connect");
        $supplier.emit(($socket, $chain, $header, Buf.new()));
        BlkMeV::Net::read_loop($socket, $chain, $supplier, $master_switch);
      });

      $supply.tap( -> ($socket, $chain, $header, $payload) {
        dispatch($socket, $chain, $header, $payload, @mempool, $master_switch)
      });
    }

    our sub dispatch($socket,
                     BlkMeV::Chain::Chain $chain,
                     BlkMeV::Header::Header $header,
                     Buf $payload,
                     @mempool,
                     Channel $master_switch) {

      if $header.command eq "+connect" {
        my $v = Command::Version.new;
        my $payload = $v.build($chain);
        my $msg = BlkMeV::Protocol::push($chain, "version", $payload);
        say "sending version {$chain.protocol_version} {$chain.user_agent} block height {$chain.block_height} payload len {$msg.elems-24}";
        $socket.write($msg);
      }

      if $header.command eq "version" {
        my $v = Command::Version.new;
        $v.fromBuf($payload);
        say "Connected to: {$v.user_agent} version #{$v.protocol_version} height #{$v.block_height}";

        my $msg = verack($chain);
        say "send verack";
        $socket.write($msg);
      }

      if $header.command eq "verack" {
        # peer accepted us, find other peers
        $socket.write(BlkMeV::Protocol::push($chain, "getaddr", Buf.new()));
      }

      if $header.command eq "addr" {
        my $a = BlkMeV::Command::Addr::Addr.new;
        $a.fromBuf($payload);
        say "peers: {$a.addrs[0]} ... {$a.addrs.elems} peer addresses";
        my @ipv4s = $a.addrs.grep({$_[0].substr(0,1) ne '['});
        for @ipv4s { client(@mempool, $chain, $_[0], $master_switch) }
      }

      if $header.command eq "reject" {
        my $c = BlkMeV::Command::Reject::Reject.new;
        $c.fromBuf($payload);
        say "Rejected: {$c.code.perl} {$c.message.perl}";
      }

      if $header.command eq "inv" {
        my $c = BlkMeV::Command::Inv::Inv.new;
        $c.fromBuf($payload);
        for $c.vectors {
          my $hexitem = BlkMeV::Util::bufToHex($_[1]);
          my $DUP = "";
          if @mempool.index($hexitem) {
            $DUP = "DUP";
          } else {
            @mempool.push($hexitem);
          }
          say "{$c.typeName($_[0])} {$hexitem} mempool#{@mempool.elems} {$DUP}";
        }
      }

      if $header.command eq "ping" {
        say "ping/pong {BlkMeV::Util::bufToHex($payload)}";
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
      done => ->  { say "async IO done" } ,
      quit => ->  { say "async IO quit" });
    }
  }
}