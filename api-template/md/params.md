| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
<% params.forEach(function(param) { var tag = getTag(param, tags); if (tag) { %>| `<%= tag.name %>` | <% if (tag.type && tag.type.name) print(tag.type.name); %> | - | <%- tag.description %> |
<% }}) %>