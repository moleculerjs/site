title: Middlewares
---

## Middlewares
Broker supports middlewares. You can add your custom middlewares, and it will be called before/after every local request. The middleware is a `Function` that returns a wrapped action handler.

**Example middleware from the validator modules**
```js
return function validatorMiddleware(handler, action) {
    // Wrap a param validator if `action.params` is defined
    if (_.isObject(action.params)) {
        return ctx => {
            this.validate(action.params, ctx.params);
            return handler(ctx);
        };
    }
    return handler;

}.bind(this);
```

The `handler` is the action handler, which is defined in [Service](services.html) schema. The `action` is the action definition object from Service schema. The middleware should return either the original `handler` or a new wrapped handler. As you can see above, we check whether the action has a `params` props. If yes, we'll return a wrapped handler which calls the validator module before calling the original `handler`.
If the `params` property is not defined, we will return the original `handler` (skipped wrapping).

>If you don't call the original `handler` in the middleware it will break the request. You can use it in cachers. For example, if it finds the requested data in the cache, it'll return the cached data instead of calling the `handler`.

**Example code from cacher middleware**
```js
return (handler, action) => {
    return function cacherMiddleware(ctx) {
        const cacheKey = this.getCacheKey(action.name, ctx.params, action.cache.keys);
        const content = this.get(cacheKey);
        if (content != null) {
            // Found in the cache! Don't call handler, return with the cached content
            ctx.cachedResult = true;
            return Promise.resolve(content);
        }

        // Call the handler
        return handler(ctx).then(result => {
            // Afterwards save the response to the cache
            this.set(cacheKey, result);

            return result;
        });
    }.bind(this);
};
```
> The `handler` always returns a `Promise`. It means that you can access to responses and manipulate them.


<div align="center">
![Broker lifecycle diagram](assets/middlewares.svg)
</div>