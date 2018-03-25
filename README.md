##

the bitcoin protocol in perl6, because why not. a command line tool for building hashlock/timelock transactions and watching the mempool as the atomic swap process progresses.

```
$ ./bin/blkmev
connecting seed.bitcoin.sipa.be
send version 100004 /BlkMeV:0.1.0/ payload 99
chain: Bitcoin Received: VERSION (102 bytes)
Connected to: /Satoshi:0.16.0/ #515074
send verack
chain: Bitcoin Received: VERACK (0 bytes)
send getinfo
chain: Bitcoin Received: SENDHEADERS (0 bytes)
chain: Bitcoin Received: SENDCMPCT (9 bytes)
chain: Bitcoin Received: SENDCMPCT (9 bytes)
chain: Bitcoin Received: PING (8 bytes)
chain: Bitcoin Received: GETHEADERS (997 bytes)
chain: Bitcoin Received: FEEFILTER (8 bytes)
chain: Bitcoin Received: INV (181 bytes)
```