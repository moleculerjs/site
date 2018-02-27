title: Service
---



# Service




`new Service()`

Main Service class








## Instance Members



### parseServiceSchema



`parseServiceSchema(schema: Object)`

Parse Service schema & register as local service


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | Object | - | of Service |









## Static Members



### waitForServices



`waitForServices(serviceNames, timeout: Number, interval: Number): Promise`

Wait for other services


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceNames` |  | - | - |
| `timeout` | Number | - | Timeout in milliseconds |
| `interval` | Number | - | Check interval in milliseconds |








### applyMixins



`applyMixins(schema: Schema): Schema`

Apply 


#### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | Schema | - | - |









