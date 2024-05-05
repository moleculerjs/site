title: Service
---



# Service




`new Service(broker, schema)`

Service class








## Instance Members



### parseServiceSchema



`parseServiceSchema(schema: Object)`

Parse Service schema & register as local service


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | Object | - | of Service |



### applyMixins



`applyMixins(schema: Schema): Schema`

Apply 


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | Schema | - | - |








### mergeSchemas



`mergeSchemas(mixinSchema: Object, svcSchema: Object): Object`

Merge two Service schema


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mixinSchema` | Object | - | Mixin schema |
| `svcSchema` | Object | - | Service schema |










## Static Members



### constructor



`new Service(broker: ServiceBroker, schema: Object)`

Creates an instance of Service by schema.


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | broker of service |
| `schema` | Object | - | schema of service |








### waitForServices



`waitForServices(serviceNames, timeout: Number, interval: Number): Promise`

Wait for other services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceNames` |  | - | - |
| `timeout` | Number | - | Timeout in milliseconds |
| `interval` | Number | - | Check interval in milliseconds |













