title: Benchmark
---
Under development we measure every important parts of the framework that we can ensure the best performance.

## Request times
We [tested](https://github.com/icebob/microservices-benchmark) Moleculer against some other frameworks and measured the request times.

### Local request
```
Suite: Call local actions
√ Seneca*                 12,081 rps
√ Nanoservices*           64,921 rps
√ Moleculer*             723,033 rps

   Seneca* (#)             0%         (12,081 rps)   (avg: 82μs)
   Nanoservices*      +437.4%         (64,921 rps)   (avg: 15μs)
   Moleculer*        +5,885.11%        (723,033 rps)   (avg: 1μs)
```
[![Result chart](https://cloud.highcharts.com/images/utideti/5/600.png)](http://cloud.highcharts.com/show/utideti)

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
- **Node**: 6.10.0
- **v8**: 5.1.281.93
- **CPU**: Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz × 8
- **Memory**: 16 GB

### Common test suite
```
Suite: Local call
√ broker.call (normal)*             1,244,250 rps
√ broker.call (with params)*        1,220,171 rps

   broker.call (normal)* (#)            0%      (1,244,250 rps)   (avg: 803ns)
   broker.call (with params)*       -1.94%      (1,220,171 rps)   (avg: 819ns)
-----------------------------------------------------------------------

Suite: Call with middlewares
√ No middlewares*        1,123,681 rps
√ 5 middlewares*         1,159,550 rps

   No middlewares* (#)       0%      (1,123,681 rps)   (avg: 889ns)
   5 middlewares*        +3.19%      (1,159,550 rps)   (avg: 862ns)
-----------------------------------------------------------------------

Suite: Call with statistics & metrics
√ No statistics*                    1,184,427 rps
√ With metrics*                       305,400 rps
√ With metrics & statistics*          280,921 rps

   No statistics* (#)                   0%      (1,184,427 rps)   (avg: 844ns)
   With metrics*                   -74.22%        (305,400 rps)   (avg: 3μs)
   With metrics & statistics*      -76.28%        (280,921 rps)   (avg: 3μs)
-----------------------------------------------------------------------

Suite: Remote call with FakeTransporter
√ Remote call echo.reply*           70,667 rps

   Remote call echo.reply*           0%         (70,667 rps)   (avg: 14μs)
-----------------------------------------------------------------------
```

### Calling test suite
```
Suite: Call methods
√ broker.call (normal)*             1,239,453 rps
√ broker.call (with params)*        1,181,153 rps

   broker.call (normal)* (#)            0%      (1,239,453 rps)   (avg: 806ns)
   broker.call (with params)*        -4.7%      (1,181,153 rps)   (avg: 846ns)
-----------------------------------------------------------------------

Suite: Call with middlewares
√ Call without middlewares*        1,200,847 rps
√ Call with 1 middleware*          1,195,808 rps
√ Call with 5 middlewares*         1,195,328 rps

   Call without middlewares* (#)       0%      (1,200,847 rps)   (avg: 832ns)
   Call with 1 middleware*         -0.42%      (1,195,808 rps)   (avg: 836ns)
   Call with 5 middlewares*        -0.46%      (1,195,328 rps)   (avg: 836ns)
-----------------------------------------------------------------------

Suite: Call with cachers
√ No cacher*                            1,054,783 rps
√ Built-in cacher*                        226,415 rps
√ Built-in cacher (keys filter)*          794,494 rps

   No cacher* (#)                           0%      (1,054,783 rps)   (avg: 948ns)
   Built-in cacher*                    -78.53%        (226,415 rps)   (avg: 4μs)
   Built-in cacher (keys filter)*      -24.68%        (794,494 rps)   (avg: 1μs)
-----------------------------------------------------------------------

Suite: Call with param validator
√ No validator*                   975,769 rps
√ With validator passes*          858,968 rps
√ With validator fail*             56,250 rps

   No validator* (#)                0%        (975,769 rps)   (avg: 1μs)
   With validator passes*      -11.97%        (858,968 rps)   (avg: 1μs)
   With validator fail*        -94.24%         (56,250 rps)   (avg: 17μs)
-----------------------------------------------------------------------

Suite: Call with statistics & metrics
√ No statistics*                    1,170,614 rps
√ With metrics*                       337,038 rps
√ With statistics*                  1,190,222 rps
√ With metrics & statistics*          306,707 rps

   No statistics* (#)                   0%      (1,170,614 rps)   (avg: 854ns)
   With metrics*                   -71.21%        (337,038 rps)   (avg: 2μs)
   With statistics*                 +1.68%      (1,190,222 rps)   (avg: 840ns)
   With metrics & statistics*       -73.8%        (306,707 rps)   (avg: 3μs)
-----------------------------------------------------------------------
```

### Cachers test suite
```
Suite: Set & get 1k data with cacher
√ Memory*           1,949,992 rps
√ MemoryMap         4,753,352 rps
√ Redis*               11,533 rps

   Memory*         -58.98%      (1,949,992 rps)   (avg: 512ns)
   MemoryMap            0%      (4,753,352 rps)   (avg: 210ns)
   Redis*          -99.76%         (11,533 rps)   (avg: 86μs)
-----------------------------------------------------------------------

Suite: Test getCacheKey
√ Dynamic           507,894 rps
√ Static         19,409,900 rps

   Dynamic       -97.38%        (507,894 rps)   (avg: 1μs)
   Static             0%     (19,409,900 rps)   (avg: 51ns)
-----------------------------------------------------------------------
```

### Events test suite
```
Suite: Emit event
√ Emit event without subscribers                                     2,161,567 rps
√ Emit simple event to 1 subscribers                                 1,785,380 rps
√ Emit simple event to 20 subscribers                                1,076,511 rps
√ Emit wildcard event to 20 subscribers                                977,945 rps
√ Emit multi-wildcard event to 20 subscribers without params           894,379 rps
√ Emit multi-wildcard event to 20 subscribers with params              880,544 rps

   Emit event without subscribers (#)                                    0%      (2,161,567 rps)   (avg: 462ns)
   Emit simple event to 1 subscribers                                -17.4%      (1,785,380 rps)   (avg: 560ns)
   Emit simple event to 20 subscribers                               -50.2%      (1,076,511 rps)   (avg: 928ns)
   Emit wildcard event to 20 subscribers                            -54.76%        (977,945 rps)   (avg: 1μs)
   Emit multi-wildcard event to 20 subscribers without params       -58.62%        (894,379 rps)   (avg: 1μs)
   Emit multi-wildcard event to 20 subscribers with params          -59.26%        (880,544 rps)   (avg: 1μs)
-----------------------------------------------------------------------
```

### Middlewares test suite
```
Suite: Middleware test
√ Without middlewares*        1,368,899 rps
√ With 1 middlewares*         1,007,793 rps
√ With 10 middlewares*        1,343,916 rps

   Without middlewares* (#)       0%      (1,368,899 rps)   (avg: 730ns)
   With 1 middlewares*       -26.38%      (1,007,793 rps)   (avg: 992ns)
   With 10 middlewares*       -1.83%      (1,343,916 rps)   (avg: 744ns)
-----------------------------------------------------------------------
```

### Transporters test suite
```
Suite: Transport with 10bytes
√ Fake*            74,742 rps
√ NATS*             8,651 rps
√ Redis*            7,897 rps
√ MQTT*             7,992 rps

   Fake* (#)        0%         (74,742 rps)   (avg: 13μs)
   NATS*       -88.43%          (8,651 rps)   (avg: 115μs)
   Redis*      -89.43%          (7,897 rps)   (avg: 126μs)
   MQTT*       -89.31%          (7,992 rps)   (avg: 125μs)
-----------------------------------------------------------------------
```

### Serializers test suite
```
JSON length: 177
Avro length: 75
MsgPack length: 137
ProtoBuf length: 82
Suite: Serialize event packet with 10bytes
√ JSON             1,127,978 rps
√ Avro               921,266 rps
√ MsgPack             98,007 rps
√ ProtoBuf           826,795 rps

   JSON (#)            0%      (1,127,978 rps)   (avg: 886ns)
   Avro           -18.33%        (921,266 rps)   (avg: 1μs)
   MsgPack        -91.31%         (98,007 rps)   (avg: 10μs)
   ProtoBuf        -26.7%        (826,795 rps)   (avg: 1μs)
-----------------------------------------------------------------------

Suite: Serialize request packet with 10bytes
√ JSON               621,247 rps
√ Avro               585,392 rps
√ MsgPack             53,962 rps
√ ProtoBuf           476,540 rps

   JSON (#)            0%        (621,247 rps)   (avg: 1μs)
   Avro            -5.77%        (585,392 rps)   (avg: 1μs)
   MsgPack        -91.31%         (53,962 rps)   (avg: 18μs)
   ProtoBuf       -23.29%        (476,540 rps)   (avg: 2μs)
-----------------------------------------------------------------------

JSON length: 331
Avro length: 216
MsgPack length: 278
ProtoBuf length: 223
Suite: Serialize event packet with 150bytes
√ JSON               461,563 rps
√ Avro               351,653 rps
√ MsgPack             80,712 rps
√ ProtoBuf           377,706 rps

   JSON (#)            0%        (461,563 rps)   (avg: 2μs)
   Avro           -23.81%        (351,653 rps)   (avg: 2μs)
   MsgPack        -82.51%         (80,712 rps)   (avg: 12μs)
   ProtoBuf       -18.17%        (377,706 rps)   (avg: 2μs)
-----------------------------------------------------------------------

Suite: Serialize request packet with 150bytes
√ JSON               346,086 rps
√ Avro               292,872 rps
√ MsgPack             44,776 rps
√ ProtoBuf           277,967 rps

   JSON (#)            0%        (346,086 rps)   (avg: 2μs)
   Avro           -15.38%        (292,872 rps)   (avg: 3μs)
   MsgPack        -87.06%         (44,776 rps)   (avg: 22μs)
   ProtoBuf       -19.68%        (277,967 rps)   (avg: 3μs)
-----------------------------------------------------------------------

JSON length: 1301
Avro length: 1118
MsgPack length: 1181
ProtoBuf length: 1125
Suite: Serialize event packet with 1kbytes
√ JSON               122,647 rps
√ Avro               104,191 rps
√ MsgPack             57,945 rps
√ ProtoBuf           141,024 rps

   JSON (#)            0%        (122,647 rps)   (avg: 8μs)
   Avro           -15.05%        (104,191 rps)   (avg: 9μs)
   MsgPack        -52.75%         (57,945 rps)   (avg: 17μs)
   ProtoBuf       +14.98%        (141,024 rps)   (avg: 7μs)
-----------------------------------------------------------------------

Suite: Serialize request packet with 1kbytes
√ JSON               112,659 rps
√ Avro                99,252 rps
√ MsgPack             38,276 rps
√ ProtoBuf           121,798 rps

   JSON (#)            0%        (112,659 rps)   (avg: 8μs)
   Avro            -11.9%         (99,252 rps)   (avg: 10μs)
   MsgPack        -66.02%         (38,276 rps)   (avg: 26μs)
   ProtoBuf        +8.11%        (121,798 rps)   (avg: 8μs)
-----------------------------------------------------------------------

JSON length: 11344
Avro length: 10516
MsgPack length: 10578
ProtoBuf length: 10522
Suite: Serialize event packet with 10kbytes
√ JSON                14,996 rps
√ Avro                13,267 rps
√ MsgPack             14,009 rps
√ ProtoBuf            21,902 rps

   JSON (#)            0%         (14,996 rps)   (avg: 66μs)
   Avro           -11.53%         (13,267 rps)   (avg: 75μs)
   MsgPack         -6.58%         (14,009 rps)   (avg: 71μs)
   ProtoBuf       +46.05%         (21,902 rps)   (avg: 45μs)
-----------------------------------------------------------------------

Suite: Serialize request packet with 10kbytes
√ JSON                15,310 rps
√ Avro                12,822 rps
√ MsgPack             12,595 rps
√ ProtoBuf            20,763 rps

   JSON (#)            0%         (15,310 rps)   (avg: 65μs)
   Avro           -16.25%         (12,822 rps)   (avg: 77μs)
   MsgPack        -17.73%         (12,595 rps)   (avg: 79μs)
   ProtoBuf       +35.61%         (20,763 rps)   (avg: 48μs)
-----------------------------------------------------------------------

JSON length: 54317
Avro length: 50589
MsgPack length: 50651
ProtoBuf length: 50596
Suite: Serialize event packet with 50kbytes
√ JSON                 3,319 rps
√ Avro                 2,893 rps
√ MsgPack              3,657 rps
√ ProtoBuf             4,549 rps

   JSON (#)            0%          (3,319 rps)   (avg: 301μs)
   Avro           -12.83%          (2,893 rps)   (avg: 345μs)
   MsgPack        +10.19%          (3,657 rps)   (avg: 273μs)
   ProtoBuf       +37.06%          (4,549 rps)   (avg: 219μs)
-----------------------------------------------------------------------

Suite: Serialize request packet with 50kbytes
√ JSON                 3,307 rps
√ Avro                 2,872 rps
√ MsgPack              3,478 rps
√ ProtoBuf             4,527 rps

   JSON (#)            0%          (3,307 rps)   (avg: 302μs)
   Avro           -13.14%          (2,872 rps)   (avg: 348μs)
   MsgPack         +5.19%          (3,478 rps)   (avg: 287μs)
   ProtoBuf       +36.89%          (4,527 rps)   (avg: 220μs)
-----------------------------------------------------------------------

JSON length: 108442
Avro length: 101088
MsgPack length: 101152
ProtoBuf length: 101095
Suite: Serialize event packet with 100kbytes
√ JSON                 1,679 rps
√ Avro                 1,462 rps
√ MsgPack              1,936 rps
√ ProtoBuf             2,325 rps

   JSON (#)            0%          (1,679 rps)   (avg: 595μs)
   Avro           -12.97%          (1,462 rps)   (avg: 684μs)
   MsgPack        +15.26%          (1,936 rps)   (avg: 516μs)
   ProtoBuf       +38.42%          (2,325 rps)   (avg: 430μs)
-----------------------------------------------------------------------

Suite: Serialize request packet with 100kbytes
√ JSON                 1,683 rps
√ Avro                 1,464 rps
√ MsgPack              1,890 rps
√ ProtoBuf             2,357 rps

   JSON (#)            0%          (1,683 rps)   (avg: 594μs)
   Avro              -13%          (1,464 rps)   (avg: 682μs)
   MsgPack        +12.32%          (1,890 rps)   (avg: 529μs)
   ProtoBuf       +40.08%          (2,357 rps)   (avg: 424μs)
-----------------------------------------------------------------------

JSON length: 1082692
Avro length: 1010070
MsgPack length: 1010134
ProtoBuf length: 1010077
Suite: Serialize event packet with 1Mbytes
√ JSON                   158 rps
√ Avro                   131 rps
√ MsgPack                191 rps
√ ProtoBuf               193 rps

   JSON (#)            0%            (158 rps)   (avg: 6ms)
   Avro           -17.29%            (131 rps)   (avg: 7ms)
   MsgPack        +21.13%            (191 rps)   (avg: 5ms)
   ProtoBuf       +22.28%            (193 rps)   (avg: 5ms)
-----------------------------------------------------------------------

Suite: Serialize request packet with 1Mbytes
√ JSON                   157 rps
√ Avro                   131 rps
√ MsgPack                190 rps
√ ProtoBuf               192 rps

   JSON (#)            0%            (157 rps)   (avg: 6ms)
   Avro           -16.91%            (131 rps)   (avg: 7ms)
   MsgPack        +21.22%            (190 rps)   (avg: 5ms)
   ProtoBuf       +22.22%            (192 rps)   (avg: 5ms)
-----------------------------------------------------------------------

```