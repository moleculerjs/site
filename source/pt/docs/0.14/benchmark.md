title: Benchmark
---
No desenvolvimento, medimos todas as partes críticas do framework para garantir o melhor desempenho possível.

## Tempos de Requisição
Nós [testamos](https://github.com/icebob/microservices-benchmark) Moleculer em relação a outros frameworks e comparamos os tempos de requisição.

### Requisição local
```
Suite: Call local actions
√ Moleculer*           1,713,579 rps
√ Nanoservices*           90,510 rps
√ Seneca*                 13,252 rps

   Moleculer*              0%      (1,713,579 rps)   (avg: 583ns)
   Nanoservices*      -94.72%         (90,510 rps)   (avg: 11μs)
   Seneca*            -99.23%         (13,252 rps)   (avg: 75μs)
```
[![Gráfico de resultados](assets/benchmark/benchmark_local.svg)](http://cloud.highcharts.com/show/utideti)

### Requisição remota
```
Suite: Call remote actions
√ Moleculer*           10,445 rps
√ Hemera*               6,655 rps
√ Cote*                15,442 rps
√ Seneca*               2,947 rps

   Moleculer*      -32.36%         (10,445 rps)   (avg: 95μs)
   Hemera*          -56.9%          (6,655 rps)   (avg: 150μs)
   Cote*                0%         (15,442 rps)   (avg: 64μs)
   Seneca*         -80.91%          (2,947 rps)   (avg: 339μs)
```
[![Gráfico de resultados](assets/benchmark/benchmark_remote.svg)](http://cloud.highcharts.com/show/abyfite)

## Resultados do Benchmark

**Plataforma:**
- **OS**: Windows_NT 6.1.7601 x64
- **Node**: 8.11.0
- **v8**: 6.2.414.50
- **CPU**: Intel(R) Core(TM) i7-4770K CPU @ 3.50GHz × 8
- **Memória**: 16 GB

### Teste simples
```
Suite: Local call
√ broker.call (normal)*             1,595,635 rps
√ broker.call (with params)*        1,662,917 rps

   broker.call (normal)* (#)            0%      (1,595,635 rps)   (avg: 626ns)
   broker.call (with params)*       +4.22%      (1,662,917 rps)   (avg: 601ns)
-----------------------------------------------------------------------

Suite: Call with middlewares
√ No middlewares*        1,621,427 rps
√ 5 middlewares*           664,141 rps

   No middlewares* (#)       0%      (1,621,427 rps)   (avg: 616ns)
   5 middlewares*       -59.04%        (664,141 rps)   (avg: 1μs)
-----------------------------------------------------------------------

Suite: Call with metrics
√ No metrics*          1,546,373 rps
√ With metrics*          486,737 rps

   No metrics* (#)         0%      (1,546,373 rps)   (avg: 646ns)
   With metrics*      -68.52%        (486,737 rps)   (avg: 2μs)
-----------------------------------------------------------------------

Suite: Remote call with FakeTransporter
√ Remote call echo.reply*                         42,409 rps
√ Remote call echo.reply with tracking*           45,739 rps

   Remote call echo.reply* (#)                     0%         (42,409 rps)   (avg: 23μs)
   Remote call echo.reply with tracking*       +7.85%         (45,739 rps)   (avg: 21μs)
-----------------------------------------------------------------------

Suite: Context tracking
√ broker.call (without tracking)*        1,606,966 rps
√ broker.call (with tracking)*           1,588,692 rps

   broker.call (without tracking)* (#)       0%      (1,606,966 rps)   (avg: 622ns)
   broker.call (with tracking)*          -1.14%      (1,588,692 rps)   (avg: 629ns)
-----------------------------------------------------------------------
```

### Teste de chamadas
```
Suite: Call methods
√ broker.call (normal)*             1,660,419 rps
√ broker.call (with params)*        1,706,815 rps

   broker.call (normal)* (#)            0%      (1,660,419 rps)   (avg: 602ns)
   broker.call (with params)*       +2.79%      (1,706,815 rps)   (avg: 585ns)
-----------------------------------------------------------------------

Suite: Call with middlewares
√ Call without middlewares*        1,604,740 rps
√ Call with 1 middleware*          1,195,061 rps
√ Call with 5 middlewares*           655,822 rps

   Call without middlewares* (#)       0%      (1,604,740 rps)   (avg: 623ns)
   Call with 1 middleware*        -25.53%      (1,195,061 rps)   (avg: 836ns)
   Call with 5 middlewares*       -59.13%        (655,822 rps)   (avg: 1μs)
-----------------------------------------------------------------------

Suite: Call with cachers
√ No cacher*                            1,180,739 rps
√ Built-in cacher*                        611,911 rps
√ Built-in cacher (keys filter)*          893,071 rps

   No cacher* (#)                           0%      (1,180,739 rps)   (avg: 846ns)
   Built-in cacher*                    -48.18%        (611,911 rps)   (avg: 1μs)
   Built-in cacher (keys filter)*      -24.36%        (893,071 rps)   (avg: 1μs)
-----------------------------------------------------------------------

Suite: Call with param validator
√ No validator*                 1,192,808 rps
√ With validator passes*        1,138,172 rps
√ With validator fail*              4,829 rps

   No validator* (#)                0%      (1,192,808 rps)   (avg: 838ns)
   With validator passes*       -4.58%      (1,138,172 rps)   (avg: 878ns)
   With validator fail*         -99.6%          (4,829 rps)   (avg: 207μs)
-----------------------------------------------------------------------

Suite: Call with metrics
√ No metrics*          1,601,825 rps
√ With metrics*          493,759 rps

   No metrics* (#)         0%      (1,601,825 rps)   (avg: 624ns)
   With metrics*      -69.18%        (493,759 rps)   (avg: 2μs)
-----------------------------------------------------------------------
```

### Teste de Cache
```
Suite: Set & get 1k data with cacher
√ Memory*        2,233,922 rps
√ Redis*            10,729 rps

   Memory*           0%      (2,233,922 rps)   (avg: 447ns)
   Redis*       -99.52%         (10,729 rps)   (avg: 93μs)
-----------------------------------------------------------------------

Suite: Test getCacheKey
√ Dynamic         2,783,031 rps
√ Static          6,787,824 rps

   Dynamic          -59%      (2,783,031 rps)   (avg: 359ns)
   Static             0%      (6,787,824 rps)   (avg: 147ns)
-----------------------------------------------------------------------

Suite: Test cloning on MemoryCacher
√ Without cloning*        4,608,810 rps
√ With cloning*             182,449 rps

   Without cloning*           0%      (4,608,810 rps)   (avg: 216ns)
   With cloning*         -96.04%        (182,449 rps)   (avg: 5μs)
-----------------------------------------------------------------------
```

### Teste de Eventos
```
Suite: Emit event
√ Emit event without subscribers                                     7,093,574 rps
√ Emit simple event to 1 subscribers                                 6,318,996 rps
√ Emit simple event to 20 subscribers                                6,428,321 rps
√ Emit wildcard event to 20 subscribers                              6,684,002 rps
√ Emit multi-wildcard event to 20 subscribers without params         7,176,790 rps
√ Emit multi-wildcard event to 20 subscribers with params            6,577,082 rps

   Emit event without subscribers (#)                                    0%      (7,093,574 rps)   (avg: 140ns)
   Emit simple event to 1 subscribers                               -10.92%      (6,318,996 rps)   (avg: 158ns)
   Emit simple event to 20 subscribers                               -9.38%      (6,428,321 rps)   (avg: 155ns)
   Emit wildcard event to 20 subscribers                             -5.77%      (6,684,002 rps)   (avg: 149ns)
   Emit multi-wildcard event to 20 subscribers without params        +1.17%      (7,176,790 rps)   (avg: 139ns)
   Emit multi-wildcard event to 20 subscribers with params           -7.28%      (6,577,082 rps)   (avg: 152ns)
-----------------------------------------------------------------------
```

### Teste de Middlewares
```
Suite: Middleware test
√ Without internal & custom middlewares*        2,786,666 rps
√ Without custom middlewares*                   1,745,153 rps
√ With 1 middlewares*                           1,270,108 rps
√ With 10 middlewares*                            473,433 rps

   Without internal & custom middlewares*      +59.68%      (2,786,666 rps)   (avg: 358ns)
   Without custom middlewares* (#)                  0%      (1,745,153 rps)   (avg: 573ns)
   With 1 middlewares*                         -27.22%      (1,270,108 rps)   (avg: 787ns)
   With 10 middlewares*                        -72.87%        (473,433 rps)   (avg: 2μs)
-----------------------------------------------------------------------
```

### Teste de transporters
```
Suite: Transport with 10bytes
√ Fake*            40,182 rps
√ NATS*             8,182 rps
√ Redis*            6,922 rps
√ MQTT*             6,985 rps
√ TCP*             10,639 rps

   Fake* (#)        0%         (40,182 rps)   (avg: 24μs)
   NATS*       -79.64%          (8,182 rps)   (avg: 122μs)
   Redis*      -82.77%          (6,922 rps)   (avg: 144μs)
   MQTT*       -82.62%          (6,985 rps)   (avg: 143μs)
   TCP*        -73.52%         (10,639 rps)   (avg: 93μs)
-----------------------------------------------------------------------
```

### Teste de Serializadores
```
JSON length: 89
Avro length: 38
MsgPack length: 69
ProtoBuf length: 45
Thrift length: 76
Suite: Serialize packet with 10bytes
√ JSON               811,290 rps
√ Avro               624,283 rps
√ MsgPack             76,703 rps
√ ProtoBuf           770,425 rps
√ Thrift             110,583 rps

   JSON (#)            0%        (811,290 rps)   (avg: 1μs)
   Avro           -23.05%        (624,283 rps)   (avg: 1μs)
   MsgPack        -90.55%         (76,703 rps)   (avg: 13μs)
   ProtoBuf        -5.04%        (770,425 rps)   (avg: 1μs)
   Thrift         -86.37%        (110,583 rps)   (avg: 9μs)
-----------------------------------------------------------------------

JSON length: 229
Avro length: 179
MsgPack length: 210
ProtoBuf length: 200
Thrift length: 258
Suite: Serialize packet with 150bytes
√ JSON               437,439 rps
√ Avro               348,092 rps
√ MsgPack             63,000 rps
√ ProtoBuf           408,807 rps
√ Thrift              93,022 rps

   JSON (#)            0%        (437,439 rps)   (avg: 2μs)
   Avro           -20.42%        (348,092 rps)   (avg: 2μs)
   MsgPack         -85.6%         (63,000 rps)   (avg: 15μs)
   ProtoBuf        -6.55%        (408,807 rps)   (avg: 2μs)
   Thrift         -78.73%         (93,022 rps)   (avg: 10μs)
-----------------------------------------------------------------------

JSON length: 1131
Avro length: 1081
MsgPack length: 1113
ProtoBuf length: 1170
Thrift length: 1364
Suite: Serialize packet with 1kbytes
√ JSON               148,417 rps
√ Avro               125,403 rps
√ MsgPack             17,387 rps
√ ProtoBuf           143,478 rps
√ Thrift              63,276 rps

   JSON (#)            0%        (148,417 rps)   (avg: 6μs)
   Avro           -15.51%        (125,403 rps)   (avg: 7μs)
   MsgPack        -88.29%         (17,387 rps)   (avg: 57μs)
   ProtoBuf        -3.33%        (143,478 rps)   (avg: 6μs)
   Thrift         -57.37%         (63,276 rps)   (avg: 15μs)
-----------------------------------------------------------------------

JSON length: 10528
Avro length: 10479
MsgPack length: 10510
ProtoBuf length: 11213
Thrift length: 12699
Suite: Serialize packet with 10kbytes
√ JSON                19,147 rps
√ Avro                18,598 rps
√ MsgPack              2,343 rps
√ ProtoBuf            20,118 rps
√ Thrift              14,284 rps

   JSON (#)            0%         (19,147 rps)   (avg: 52μs)
   Avro            -2.86%         (18,598 rps)   (avg: 53μs)
   MsgPack        -87.77%          (2,343 rps)   (avg: 426μs)
   ProtoBuf        +5.07%         (20,118 rps)   (avg: 49μs)
   Thrift         -25.39%         (14,284 rps)   (avg: 70μs)
-----------------------------------------------------------------------

JSON length: 50601
Avro length: 50552
MsgPack length: 50583
ProtoBuf length: 54187
Thrift length: 61472
Suite: Serialize packet with 50kbytes
√ JSON                 4,110 rps
√ Avro                 4,032 rps
√ MsgPack                481 rps
√ ProtoBuf             4,362 rps
√ Thrift               3,401 rps

   JSON (#)            0%          (4,110 rps)   (avg: 243μs)
   Avro             -1.9%          (4,032 rps)   (avg: 248μs)
   MsgPack         -88.3%            (481 rps)   (avg: 2ms)
   ProtoBuf        +6.13%          (4,362 rps)   (avg: 229μs)
   Thrift         -17.26%          (3,401 rps)   (avg: 294μs)
-----------------------------------------------------------------------

JSON length: 101100
Avro length: 101051
MsgPack length: 101084
ProtoBuf length: 108312
Thrift length: 122849
Suite: Serialize packet with 100kbytes
√ JSON                 2,075 rps
√ Avro                 2,045 rps
√ MsgPack                234 rps
√ ProtoBuf             2,202 rps
√ Thrift               1,752 rps

   JSON (#)            0%          (2,075 rps)   (avg: 481μs)
   Avro            -1.47%          (2,045 rps)   (avg: 488μs)
   MsgPack        -88.73%            (234 rps)   (avg: 4ms)
   ProtoBuf         +6.1%          (2,202 rps)   (avg: 454μs)
   Thrift         -15.57%          (1,752 rps)   (avg: 570μs)
-----------------------------------------------------------------------

JSON length: 1010082
Avro length: 1010033
MsgPack length: 1010066
ProtoBuf length: 1082562
Thrift length: 1227635
Suite: Serialize packet with 1Mbytes
√ JSON                   187 rps
√ Avro                   184 rps
√ MsgPack                 22 rps
√ ProtoBuf               195 rps
√ Thrift                 156 rps

   JSON (#)            0%            (187 rps)   (avg: 5ms)
   Avro            -1.81%            (184 rps)   (avg: 5ms)
   MsgPack        -88.04%             (22 rps)   (avg: 44ms)
   ProtoBuf        +4.44%            (195 rps)   (avg: 5ms)
   Thrift         -16.75%            (156 rps)   (avg: 6ms)
-----------------------------------------------------------------------

```
