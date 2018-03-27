##

the bitcoin protocol in perl6, because why not. a command line tool for building hashlock/timelock transactions and watching the mempool as the atomic swap process progresses.

```
$ ./bin/blkmev bitcoin
connecting seed.bitcoin.sipa.be:8333
connected to 35.227.54.185:8333
sending version 100004 /BlkMeV:0.1.0/ block height 500000 payload len 99
chain: Bitcoin Received: VERSION (102 bytes)
Connected to: /Satoshi:0.14.1/ #515387
send verack
chain: Bitcoin Received: VERACK (0 bytes)
chain: Bitcoin Received: SENDHEADERS (0 bytes)
chain: Bitcoin Received: SENDCMPCT (9 bytes)
chain: Bitcoin Received: SENDCMPCT (9 bytes)
chain: Bitcoin Received: PING (8 bytes)
Ping msg
chain: Bitcoin Received: GETHEADERS (997 bytes)
chain: Bitcoin Received: FEEFILTER (8 bytes)
chain: Bitcoin Received: INV (1081 bytes)
Inventory msg
Inv count 30 (using storage 1)
inventory type TX 06aa49a2e2468aed2b65cb0557f88d1710d8e13ae9e95c88a4d94f173cf70bb8
inventory type TX f76261ca5b77410fd1dca3f808350fe28d283d3d1b41a13c6fd86b7146283998
inventory type TX 84ebe6d0f9f0bd802c25fcab8ae0efb54fbce03ecd86444799fcdcadffd1821f
inventory type TX e539b96343c5bdffd52e9b51f6721b0d4289a810aab9cb2036e884c0c9cde5a3
```