use v6;
use experimental :pack;
use BlkMeV;
use BlkMeV::Header;
use BlkMeV::Protocol;
use BlkMeV::Command::Inv;
use BlkMeV::Command::Reject;
use BlkMeV::Command::Addr;
use BlkMeV::Command::Version;

package BlkMeV {
  module Net is export {

    our sub client_pool_builder(:@clientpool, :@mempool, :$master_switch) {
      my $client_supplier = Supplier.new;
      my $client_supply = $client_supplier.Supply;
      $client_supply.tap( -> ($chain, $host) {
          if @clientpool.elems < 10 {
            Net::client(@mempool, $chain, $host, $client_supplier, $master_switch);
            @clientpool.push($host);
            say "* pool new client {$chain.params.name} {$host}. pool size {@clientpool.elems}";
          } else {
            say "* client ignored. pool full at {$@clientpool.elems}"
          }
        }, #@clientpool = @clientpool.grep({$_ != $host})
        done => ->  { say "client done. {$_} remain." } ,
        quit => ->  { say "client quit. {$_} remain." }
      );
      $client_supplier
    }

    our sub client (@mempool, $chain, $host, $client_supplier, $master_switch) {
      my $message_supplier = Supplier.new;
      my $message_supply = $message_supplier.Supply;

      say "* connecting {$chain.params.name} {$host}:{$chain.params.port}";

      IO::Socket::Async.connect($host, $chain.params.port).then( -> $promise {
        my $socket = $promise.result;
        say "connected to {$socket.peer-host}:{$socket.peer-port}";
        my $header = BlkMeV::Header::Header.new;
        $header.fromStr("+connect");
        $message_supplier.emit(($socket, $chain, $header, Buf.new()));
        my $client_tap = read_loop($socket, $chain, $message_supplier, $master_switch);
        say "client tap {$client_tap}"
      });

      $message_supply.tap( -> ($socket, $chain, $header, $payload) {
          CLOSE { say "!*!--client close" }
          dispatch($socket, $chain, $header, $payload, @mempool, $client_supplier, $master_switch)
        },
        done => ->  { say "socket done. {$_} remain." } ,
        quit => ->  { say "socket quit. {$_} remain." }
      );
    }

    our sub read_loop(IO::Socket::Async $socket,
                      $chain,
                      Supplier $message_supplier,
                      Channel $master_switch) {
      my $msgbuf = Buf.new;
      my $gotHeader = False;
      my BlkMeV::Header::Header $header;
      $socket.Supply(:bin).on-close({ say "!*! sockt Tap closed" }).tap( -> $buf {
        CLOSE { say "!*!--readloop close" }
        CATCH { say "!*!--readloop catch" }
        QUIT { say "!*!--readloop quit" }
        $msgbuf.append($buf);
        if !$gotHeader {
          if $msgbuf.elems >= $BlkMeV::Header::PACKET_LENGTH {
            my $header_buf = BlkMeV::Util::bufTrim($msgbuf, $BlkMeV::Header::PACKET_LENGTH);
            $header = BlkMeV::Header::Header.new;
            $header.fromBuf($header_buf);
            $gotHeader = True;
            say "{$socket.peer-host} [{BlkMeV::Chain::chain_params_by_header($header.chain_id).name}] command: {$header.command.uc} ({$header.payload_length} bytes)";
          }
        }

        if $msgbuf.elems >= $header.payload_length {
          my $payload = BlkMeV::Util::bufTrim($msgbuf, $header.payload_length);
          $gotHeader = False;
          $message_supplier.emit(($socket, $chain, $header, $payload));
        }
      },
      done => -> { say "async IO done" } ,
      quit => -> $e { say "async IO quit {$e}" });
    }
  }

    our sub dispatch($socket,
                     BlkMeV::Chain::Chain $chain,
                     BlkMeV::Header::Header $header,
                     Buf $payload,
                     @mempool,
                     Supplier$client_supplier,
                     Channel $master_switch) {

      if $header.command eq "+connect" {
        my $v = Command::Version.new;
        my $payload = $v.build($chain);
        my $msg = BlkMeV::Protocol::push($chain, "version", $payload);
        say "sending version {$chain.params.protocol_version} {$chain.params.user_agent} block height {$chain.params.block_height} payload len {$msg.elems-24}";
        $socket.write($msg);
      }

      if $header.command eq "version" {
        my $v = Command::Version.new;
        $v.fromBuf($payload);
        say "Connected to: {$v.user_agent} version #{$v.protocol_version} height #{$v.block_height}";

        my $msg = BlkMeV::Protocol::push($chain, "verack", Buf.new());
        say "send verack";
        $socket.write($msg);
      }

      if $header.command eq "verack" {
        # BlkMeV::Protocol::push("getinfo", Buf.new());
        # peer accepted us, find other peers
        $socket.write(BlkMeV::Protocol::push($chain, "getaddr", Buf.new()));
      }

      if $header.command eq "addr" {
        my $a = BlkMeV::Command::Addr::Addr.new;
        $a.fromBuf($payload);
        say "peers: {$a.addrs[0]} ... {$a.addrs.elems} peer addresses";
        my @ipv4s = $a.addrs.grep({$_[0].substr(0,1) ne '['});
        for @ipv4s {
          $client_supplier.emit(($chain, $_[0]))
        }
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
          say "{$socket.peer-host} [{BlkMeV::Chain::chain_params_by_header($header.chain_id).name}] {$c.typeName($_[0])} {$hexitem} mempool#{@mempool.elems} {$DUP}";
        }
      }

      if $header.command eq "ping" {
        say "ping/pong {BlkMeV::Util::bufToHex($payload)}";
        $socket.write(BlkMeV::Protocol::push($chain, "pong", $payload));
      }
    }
}