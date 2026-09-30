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

### Searchable Selects

Madmin's `select` Stimulus controller turns a `<select>` into a searchable combobox. Belongs to and has many fields use it to search the associated resource, and custom fields can use it to load options from any endpoint, such as an external API.

Point `data-select-url-value` at a URL that returns JSON with an `id` and `name` for each option. The controller requests it when the field is focused, and again with the search term in `q` as you type:

```erb
<%# app/views/madmin/fields/video_field/_form.html.erb %>
<%= form.select field.attribute_name,
      record.video_id ? [[record.video_title, record.video_id]] : [],
      { include_blank: true },
      { class: "form-input", data: { controller: "select", select_url_value: madmin_video_search_path(format: :json) } } %>
```

```ruby
# GET /madmin/video_search.json?q=rails
class Madmin::VideoSearchesController < Madmin::ApplicationController
  def show
    videos = VideoClient.search(params[:q])
    render json: videos.map { |video| {id: video.guid, name: video.title} }
  end
end
```

The `<select>` stays in the form, hidden, and is what gets submitted, so the chosen `id` is saved like any other select. Include the current value as an option so it shows when editing. Add `multiple: true` to choose several values. Without a URL, the select's own options are filtered as you type.
