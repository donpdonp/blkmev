the bitcoin protocol in raku, because why not.

##
run from source
```bash
$ git clone https://github.com/donpdonp/blkmev
Cloning into 'blkmev'...
remote: Counting objects: 451, done.
remote: Compressing objects: 100% (268/268), done.
remote: Total 451 (delta 240), reused 363 (delta 152), pack-reused 0
Receiving objects: 100% (451/451), 88.04 KiB | 117.00 KiB/s, done.
Resolving deltas: 100% (240/240), done.
Checking connectivity... done.
$ cd blkmev
$ zef install .
===> Testing: BlkMev
===> Testing [OK] for BlkMev
===> Installing: BlkMev

1 bin/ script [blkmev] installed to:
~/.rakudobrew/moar-2018.04.1/install/share/perl6/site/bin
```

##
`blkmev <bitcoin|bitcoincash|litecoin|dogecoin> [seed peer]`

```
$ ./bin/blkmev dogecoin
* pool new client dogecoin {:host("seed.multidoge.org")}. pool size 1
* connecting dogecoin seed.multidoge.org:22556
176.31.106.41 [dogecoin] -> VERSION 1100004 BlkMev:dogecoin block height 2150000 payload len 100
176.31.106.41 [dogecoin] command: VERSION (105 bytes)
176.31.106.41 [dogecoin] /Shibetoshi:1.10.0/ version #70004 height #2220526
176.31.106.41 [dogecoin] -> VERACK
176.31.106.41 [dogecoin] command: VERACK (0 bytes)
176.31.106.41 [dogecoin] command: PING (8 bytes)
176.31.106.41 [dogecoin] -> pong d012d0c672c01404
176.31.106.41 [dogecoin] command: GETHEADERS (1093 bytes)
176.31.106.41 [dogecoin] command: INV (37 bytes)
176.31.106.41 [dogecoin] TX 4b5f4c7b23d52ff2c7ca6a7aec7ee66923f3887d2a306b249921926ad00a3a9d mempool#1
176.31.106.41 [dogecoin] command: ADDR (30003 bytes)
176.31.106.41 [dogecoin] peers: [20:01:00:00:9d:38:6a:bd:08:5f:17:ed:23:12:a0:19] 22556 ... 1000 peer addresses
```

## roadmap
  * build hashlock/timelock transactions and watch the mempool as the atomic swap process progresses.
