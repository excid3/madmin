## Custom Fields
You can generate a custom field with:

```bash
rails g madmin:field Custom
```

This will create a CustomField class in app/madmin/fields/custom_field.rb And the related views:

```bash
# -> app/views/madmin/fields/custom_field/_form.html.erb
# -> app/views/madmin/fields/custom_field/_index.html.erb
# -> app/views/madmin/fields/custom_field/_show.html.erb
```

You can then use this field on our resource:

```ruby
class PostResource < Madmin::Resource
  attribute :title, field: CustomField
end
```
