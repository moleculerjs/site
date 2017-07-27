<% members.forEach(function(member) { %>

### <%= member.name %>
<% if (member.deprecated) { %>![Deprecated](https://img.shields.io/badge/status-deprecated-orange.svg)<% } %>
<% if (member.since) { %><sup>Since: <%= member.since %></sup><% } %>

`<%- signature(member) %>`

<%= getDesc(member.description) %>

<% if (member.params.length) { %>
### Parameters

<%= renderParams(member.params, member.tags) %><% } %>


<% if (member.properties.length) { %>
### Properties

<%= renderParams(member.properties, member.tags) %><% } %>

<% if (member.examples.length) {  %>
### Examples

<% member.examples.forEach(function(example) { %>

<% if (example.caption) { %>
**<%- getDesc(example.caption) %>**
<% } %>

```js
<%= example.description %>
```

<% }) %>
<% } %>
<% }) %>