package BlkMeV::Chain::Params {
  class Params {
    has Str $.name;
    has Buf $.header;
    has Str $.host;
    has Int $.port;
    has &.hash_func;
    has Str $.user_agent;
    has Int $.protocol_version;
    has Int $.block_height;

    #   my $user_agent = "/BlkMeV:{$params.name}:{$BlkMeV::Version}/";
  }
}