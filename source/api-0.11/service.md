title: Context
---



# Service




`new Service(broker, schema)`

Main Service class








## Instance Members



### constructor



`new Service(broker: ServiceBroker, schema: Object)`

Creates an instance of Service by schema.


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `broker` | ServiceBroker | - | broker of service |
| `schema` | Object | - | schema of service |









## Static Members



### waitForServices



`waitForServices(serviceNames, timeout: Number, interval: Number): Promise`

Wait for other services


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `serviceNames` |  | - |  |
| `timeout` | Number | - | Timeout in milliseconds |
| `interval` | Number | - | Check interval in milliseconds |








### applyMixins



`applyMixins(schema: Schema): Schema`

Apply 


### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `schema` | Schema | - |  |









