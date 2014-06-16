<% challenges.compact.each do |challenge| %>
``` <%= challenge.implementor.language %>
<%= File.read(challenge.source_file) %>
```
<% end %>