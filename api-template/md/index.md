title: Context
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

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<% params.forEach(function(param) { var tag = getTag(param, tags); if (tag) { %>| `<%= tag.name %>` | <% if (tag.type && tag.type.name) print(tag.type.name); %> | - | Context ID |
<% }}) %>

<% } %>

<% if (hasValidParam(doc.properties, doc.tags)) { var params = doc.properties, tags = doc.tags; %>
### Properties

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<% params.forEach(function(param) { var tag = getTag(param, tags); if (tag) { %>| `<%= tag.name %>` | <% if (tag.type && tag.type.name) print(tag.type.name); %> | <% if (tag.default) print("`" + tag.default + "`"); else print("-") %> | <%- tag.description %> |
<% }}) %>

<% } %>

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

<% if (doc.members.instance && doc.members.instance.length) { var members = doc.members.instance; %>
## Instance Members

<% members.forEach(function(member) { %>

### <%= member.name %>
<% if (member.deprecated) { %>![Deprecated](https://img.shields.io/badge/status-deprecated-orange.svg)<% } %>

<% if (member.since) { %>
<sup>Since: <%= member.since %></sup>
<% } %>

`<%- signature(member) %>`

<%= getDesc(member.description) %>

<% if (member.params.length) { var params = member.params, tags = member.tags; %>
### Parameters

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<% params.forEach(function(param) { var tag = getTag(param, tags); if (tag) { %>| `<%= tag.name %>` | <% if (tag.type && tag.type.name) print(tag.type.name); %> | - | Context ID |
<% }}) %>

<% } %>

<% if (member.properties.length) { var params = member.properties, tags = member.tags; %>
### Properties

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<% params.forEach(function(param) { var tag = getTag(param, tags); if (tag) { %>| `<%= tag.name %>` | <% if (tag.type && tag.type.name) print(tag.type.name); %> | <% if (tag.default) print("`" + tag.default + "`"); else print("-") %> | <%- tag.description %> |
<% }}) %>

<% } %>

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

<% } %>

<% if (doc.members.static && doc.members.static.length) { var members = doc.members.static; %>
## Static Members

<% } %>

<% }) %>
