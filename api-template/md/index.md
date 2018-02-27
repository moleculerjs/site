title: <%= name %>
---

<% docs.forEach(function(doc) { %>

# <%= doc.name %>
<% if (doc.deprecated) { %>![Deprecated](https://img.shields.io/badge/status-deprecated-orange.svg)<% } %>

<% if (doc.since) { %>
<sup>Since: <%= doc.since %></sup>
<% } %>

`<%- signature(doc) %>`

<%= getDesc(doc.description) %>

<% if (hasValidParam(doc.params, doc.tags)) { var params = doc.params, tags = doc.tags; %>
### Parameters

<%= renderParams(doc.params, doc.tags) %><% } %>

<% if (hasValidParam(doc.properties, doc.tags)) { var params = doc.properties, tags = doc.tags; %>
### Properties

<%= renderParams(doc.properties, doc.tags) %><% } %>

<% if (doc.examples.length) {  %>
### Examples

<% doc.examples.forEach(function(example) { %>

<% if (example.caption) { %>
**<%- getDesc(example.caption) %>**
<% } %>
```js
<%= example.description %>
```
<% }) %>
<% } %>

<% if (doc.members.instance && doc.members.instance.length) { %>
## Instance Members

<%= renderMembers(doc.members.instance) %><% } %>

<% if (doc.members.static && doc.members.static.length) { %>
## Static Members

<%= renderMembers(doc.members.static) %><% } %>

<% }) %>
