use BlkMeV::Header;

package BlkMeV {
  module Log is export {
    our sub say_client(IO::Socket::Async $socket, BlkMeV::Header::Header $header, Str $text) {
      say "{$socket.peer-host} [{BlkMeV::Chain::chain_params_by_header($header.chain_id).name}] {$text}";
    }
  }
}