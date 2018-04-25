module BlkMeV::Chain::BitcoinCash {
  our $name = "bitcoincash";
  our $header = Buf.new(0xe3, 0xe1, 0xf3, 0xe8);
}