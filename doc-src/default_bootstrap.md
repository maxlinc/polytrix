This code will cause Polytrix to bootstrap:

<% challenges.compact.each do |challenge| %>
``` <%= challenge.implementor.language %>
<%= File.read(challenge.source_file) %>
```

And the results will look like:
```
<%= challenge.result.execution_result.stdout %>
```

<% end %>