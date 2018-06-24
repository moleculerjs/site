title: Benchmark
---
In development, we measure every critical part of the framework to ensure the best possible performance.

## Request times
We [tested](https://github.com/icebob/microservices-benchmark) Moleculer against some other frameworks and measured the request times.

### Local request
```
Suite: Call local actions
√ Moleculer*           2,021,189 rps
√ Nanoservices*           94,116 rps
√ Seneca*                 13,621 rps

   Moleculer*              0%      (2,021,189 rps)   (avg: 494ns)
   Nanoservices*      -95.34%         (94,116 rps)   (avg: 10μs)
   Seneca*            -99.33%         (13,621 rps)   (avg: 73μs)
```
[![Result chart](https://cloud.highcharts.com/images/utideti/6/600.png)](http://cloud.highcharts.com/show/utideti)

### Remote request
```
Suite: Call remote actions
√ Seneca*               2,140 rps
√ Hemera*               4,354 rps
√ Moleculer*            8,664 rps

   Seneca* (#)          0%          (2,140 rps)   (avg: 467μs)
   Hemera*        +103.42%          (4,354 rps)   (avg: 229μs)
   Moleculer*     +304.81%          (8,664 rps)   (avg: 115μs)
```
[![Result chart](https://cloud.highcharts.com/images/abyfite/1/600.png)](http://cloud.highcharts.com/show/abyfite)

## Benchmark results

**Tester platform:**
- **OS**: Windows_NT 6.1.7601 x64
- **Node**: 8.9.4
- **v8**: 6.1.534.50
- **CPU**: Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz × 8
- **Memory**: 16 GB

### Common test suite
```
Suite: Local call
√ broker.call (normal)*             1,654,091 rps
√ broker.call (with params)*        1,846,689 rps

   broker.call (normal)* (#)            0%      (1,654,091 rps)   (avg: 604ns)
   broker.call (with params)*      +11.64%      (1,846,689 rps)   (avg: 541ns)
-----------------------------------------------------------------------

Suite: Call with middlewares
√ No middlewares*        1,660,456 rps
√ 5 middlewares*         1,588,124 rps

   No middlewares* (#)       0%      (1,660,456 rps)   (avg: 602ns)
   5 middlewares*        -4.36%      (1,588,124 rps)   (avg: 629ns)
-----------------------------------------------------------------------

Suite: Call with statistics & metrics
√ No statistics*                    1,616,265 rps
√ With metrics*                       549,124 rps
√ With statistics*                    768,617 rps
√ With metrics & statistics*          408,013 rps

   No statistics* (#)                   0%      (1,616,265 rps)   (avg: 618ns)
   With metrics*                   -66.03%        (549,124 rps)   (avg: 1μs)
   With statistics*                -52.44%        (768,617 rps)   (avg: 1μs)
   With metrics & statistics*      -74.76%        (408,013 rps)   (avg: 2μs)
-----------------------------------------------------------------------

Suite: Remote call with FakeTransporter
√ Remote call echo.reply*           45,987 rps

   Remote call echo.reply*           0%         (45,987 rps)   (avg: 21μs)
-----------------------------------------------------------------------
```

### Calling test suite
```
Suite: Call methods
√ broker.call (normal)*             1,738,486 rps
√ broker.call (with params)*        1,807,759 rps

   broker.call (normal)* (#)            0%      (1,738,486 rps)   (avg: 575ns)
   broker.call (with params)*       +3.98%      (1,807,759 rps)   (avg: 553ns)
-----------------------------------------------------------------------

Suite: Call with middlewares
√ Call without middlewares*        1,716,913 rps
√ Call with 1 middleware*          1,662,845 rps
√ Call with 5 middlewares*         1,666,777 rps

   Call without middlewares* (#)       0%      (1,716,913 rps)   (avg: 582ns)
   Call with 1 middleware*         -3.15%      (1,662,845 rps)   (avg: 601ns)
   Call with 5 middlewares*        -2.92%      (1,666,777 rps)   (avg: 599ns)
-----------------------------------------------------------------------

Suite: Call with cachers
√ No cacher*                            1,344,920 rps
√ Built-in cacher*                        315,524 rps
√ Built-in cacher (keys filter)*          964,395 rps
√ With statistics*                        811,574 rps

   No cacher* (#)                           0%      (1,344,920 rps)   (avg: 743ns)
   Built-in cacher*                    -76.54%        (315,524 rps)   (avg: 3μs)
   Built-in cacher (keys filter)*      -28.29%        (964,395 rps)   (avg: 1μs)
   With statistics*                    -39.66%        (811,574 rps)   (avg: 1μs)
-----------------------------------------------------------------------

Suite: Call with param validator
√ No validator*                 1,055,690 rps
√ With validator passes*        1,082,886 rps
√ With validator fail*              6,994 rps

   No validator* (#)                0%      (1,055,690 rps)   (avg: 947ns)
   With validator passes*       +2.58%      (1,082,886 rps)   (avg: 923ns)
   With validator fail*        -99.34%          (6,994 rps)   (avg: 142μs)
-----------------------------------------------------------------------

Suite: Call with statistics & metrics
√ No statistics*                    1,311,912 rps
√ With metrics*                       453,033 rps
√ With metrics & statistics*          396,287 rps

   No statistics* (#)                   0%      (1,311,912 rps)   (avg: 762ns)
   With metrics*                   -65.47%        (453,033 rps)   (avg: 2μs)
   With metrics & statistics*      -69.79%        (396,287 rps)   (avg: 2μs)
-----------------------------------------------------------------------
```

### Cachers test suite
```
Suite: Set & get 1k data with cacher
√ Memory*        2,066,824 rps
√ Redis*            10,915 rps

   Memory*           0%      (2,066,824 rps)   (avg: 483ns)
   Redis*       -99.47%         (10,915 rps)   (avg: 91μs)
-----------------------------------------------------------------------

Suite: Test getCacheKey
√ Dynamic           679,228 rps
√ Static          5,981,643 rps

   Dynamic       -88.64%        (679,228 rps)   (avg: 1μs)
   Static             0%      (5,981,643 rps)   (avg: 167ns)
-----------------------------------------------------------------------
```

### Events test suite
```
Suite: Emit event
√ Emit event without subscribers                                     7,450,694 rps
√ Emit simple event to 1 subscribers                                   663,669 rps
√ Emit simple event to 20 subscribers                                   41,231 rps
√ Emit wildcard event to 20 subscribers                                 30,902 rps
√ Emit multi-wildcard event to 20 subscribers without params            30,608 rps
√ Emit multi-wildcard event to 20 subscribers with params               30,355 rps

   Emit event without subscribers (#)                                    0%      (7,450,694 rps)   (avg: 134ns)
   Emit simple event to 1 subscribers                               -91.09%        (663,669 rps)   (avg: 1μs)
   Emit simple event to 20 subscribers                              -99.45%         (41,231 rps)   (avg: 24μs)
   Emit wildcard event to 20 subscribers                            -99.59%         (30,902 rps)   (avg: 32μs)
   Emit multi-wildcard event to 20 subscribers without params       -99.59%         (30,608 rps)   (avg: 32μs)
   Emit multi-wildcard event to 20 subscribers with params          -99.59%         (30,355 rps)   (avg: 32μs)
-----------------------------------------------------------------------
```

### Middlewares test suite
```
Suite: Middleware test
√ Without middlewares*        1,725,594 rps
√ With 1 middlewares*         1,395,079 rps
√ With 10 middlewares*        1,841,953 rps

   Without middlewares* (#)       0%      (1,725,594 rps)   (avg: 579ns)
   With 1 middlewares*       -19.15%      (1,395,079 rps)   (avg: 716ns)
   With 10 middlewares*       +6.74%      (1,841,953 rps)   (avg: 542ns)
-----------------------------------------------------------------------
```

### Transporters test suite
```
Suite: Transport with 10bytes
√ Fake*            55,626 rps
√ NATS*             8,729 rps
√ Redis*            8,590 rps
√ MQTT*             8,103 rps
√ TCP*             11,249 rps

   Fake* (#)        0%         (55,626 rps)   (avg: 17μs)
   NATS*       -84.31%          (8,729 rps)   (avg: 114μs)
   Redis*      -84.56%          (8,590 rps)   (avg: 116μs)
   MQTT*       -85.43%          (8,103 rps)   (avg: 123μs)
   TCP*        -79.78%         (11,249 rps)   (avg: 88μs)
-----------------------------------------------------------------------
```

### Serializers test suite
```
JSON length: 89
Avro length: 38
MsgPack length: 69
ProtoBuf length: 45
Suite: Serialize packet with 10bytes
√ JSON             1,276,006 rps
√ Avro               608,887 rps
√ MsgPack             61,587 rps
√ ProtoBuf           927,611 rps

   JSON (#)            0%      (1,276,006 rps)   (avg: 783ns)
   Avro           -52.28%        (608,887 rps)   (avg: 1μs)
   MsgPack        -95.17%         (61,587 rps)   (avg: 16μs)
   ProtoBuf        -27.3%        (927,611 rps)   (avg: 1μs)
-----------------------------------------------------------------------

JSON length: 1131
Avro length: 1081
MsgPack length: 1113
ProtoBuf length: 1170
Suite: Serialize packet with 1kbytes
√ JSON               205,813 rps
√ Avro               123,731 rps
√ MsgPack             12,661 rps
√ ProtoBuf           147,930 rps

   JSON (#)            0%        (205,813 rps)   (avg: 4μs)
   Avro           -39.88%        (123,731 rps)   (avg: 8μs)
   MsgPack        -93.85%         (12,661 rps)   (avg: 78μs)
   ProtoBuf       -28.12%        (147,930 rps)   (avg: 6μs)
-----------------------------------------------------------------------

JSON length: 10528
Avro length: 10479
MsgPack length: 10510
ProtoBuf length: 11213
Suite: Serialize packet with 10kbytes
√ JSON                26,892 rps
√ Avro                18,671 rps
√ MsgPack              1,642 rps
√ ProtoBuf            20,388 rps

   JSON (#)            0%         (26,892 rps)   (avg: 37μs)
   Avro           -30.57%         (18,671 rps)   (avg: 53μs)
   MsgPack        -93.89%          (1,642 rps)   (avg: 608μs)
   ProtoBuf       -24.18%         (20,388 rps)   (avg: 49μs)
-----------------------------------------------------------------------

JSON length: 50601
Avro length: 50552
MsgPack length: 50583
ProtoBuf length: 54187
Suite: Serialize packet with 50kbytes
√ JSON                 5,851 rps
√ Avro                 4,065 rps
√ MsgPack                338 rps
√ ProtoBuf             4,455 rps

   JSON (#)            0%          (5,851 rps)   (avg: 170μs)
   Avro           -30.53%          (4,065 rps)   (avg: 246μs)
   MsgPack        -94.22%            (338 rps)   (avg: 2ms)
   ProtoBuf       -23.86%          (4,455 rps)   (avg: 224μs)
-----------------------------------------------------------------------

JSON length: 101100
Avro length: 101051
MsgPack length: 101084
ProtoBuf length: 108312
Suite: Serialize packet with 100kbytes
√ JSON                 2,980 rps
√ Avro                 2,075 rps
√ MsgPack                169 rps
√ ProtoBuf             2,254 rps

   JSON (#)            0%          (2,980 rps)   (avg: 335μs)
   Avro           -30.36%          (2,075 rps)   (avg: 481μs)
   MsgPack        -94.34%            (169 rps)   (avg: 5ms)
   ProtoBuf       -24.39%          (2,254 rps)   (avg: 443μs)
-----------------------------------------------------------------------

JSON length: 1010082
Avro length: 1010033
MsgPack length: 1010066
ProtoBuf length: 1082562
Suite: Serialize packet with 1Mbytes
√ JSON                   300 rps
√ Avro                   188 rps
√ MsgPack                 16 rps
√ ProtoBuf               199 rps

   JSON (#)            0%            (300 rps)   (avg: 3ms)
   Avro           -37.21%            (188 rps)   (avg: 5ms)
   MsgPack        -94.51%             (16 rps)   (avg: 60ms)
   ProtoBuf       -33.69%            (199 rps)   (avg: 5ms)
-----------------------------------------------------------------------

```
