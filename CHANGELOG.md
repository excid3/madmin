### Unreleased

### 3.1.0

* Add `direct_upload: true` for attachment and file fields to upload straight to the Active Storage service. Madmin's JavaScript now starts Active Storage; fields without the option keep uploading through the form
* Remove the unused `tailwindcss-stimulus-components` pin and its `dropdown` controller, which no Madmin view has used since the move to plain CSS. Custom views that use `data-controller="dropdown"` should pin and register it in their app

### 3.0.0

* Add an array field for PostgreSQL array columns. Values are shown and edited as comma separated text, and index filters offer "includes". Array columns were treated as strings before, so filters ran `ILIKE` against them and failed
* Add filters to index pages. A Filters button opens a form for conditions on string, text, number, date, datetime and boolean columns, like "Admin is true" or "Created at after Aug 15". Active filters show as removable chips and are kept in the URL, sorting, scopes, search and pagination. Datetime values are parsed in `Time.zone`. Use `filter: false` to leave out an attribute, and `Field.filter_type` for custom fields. Customized `index.html.erb` views can add `<%= render "filters" %>` and `<%= render "active_filters" %>` #227
* Index links keep the current search, scope, sort and filters through a new `index_path_with` helper. Clearing the search no longer drops the scope
* Add a `:nested_has_one` field for editing a has one association inside the parent's form. It shows an "Add" link until the record exists, so saving the parent doesn't create an empty one #207
* Fix `:nested_has_many` looking up the associated class and resource from the attribute name, which broke for associations with `class_name` or in a namespace. It now uses the association's class
* Replace Tom Select with a small Stimulus combobox, removing the `tom-select` importmap pin and its stylesheet. Belongs to and has many fields keep the same `data-controller="select"` and `data-select-url-value` attributes, loading `[{id, name}]` JSON from the URL when focused and as you type. Search terms are now URL encoded. Enum, select and polymorphic fields use native selects. Custom views that used Tom Select options or its CSS classes (`.ts-control`, `.ts-dropdown`) need updating; apps that use Tom Select directly should pin it themselves
* Add dark mode, following the system's light or dark setting. Colors are CSS variables on `:root` defined with `light-dark()`; set `color-scheme: light` on `:root` to opt out. Adds `--link-color` for links, while `--primary-color` stays the button background. Trix and Lexxy editors get dark colors too. Custom styles with hard-coded light colors may need a dark variant
* Remove the unused flatpickr stylesheet. Madmin replaced flatpickr with native date inputs in 2.0.1; apps that still use flatpickr in custom fields should include its stylesheet themselves
* **Breaking:** Replace Pagy with built-in pagination (`Madmin::Pagination` and `Madmin::Page`). The `pagy` gem is no longer a dependency.
  * Customized `index.html.erb` views should replace the `pagy_nav` / `@pagy.series_nav` block with `<%= render "pagination", page: @page %>`
  * `paginate_collection` overrides must return `[page, records]` where `page` responds to the `Madmin::Page` interface (`page`, `last`, `count`, `from`, `to`, `prev`, `next`, `series`, `param`)
  * Set the page size with `Madmin.per_page = 20` instead of Pagy's options
  * The `.pagy` CSS class is now `.pagination .pages`
  * Index queries append the primary key to the ordering so rows with equal sort values stay stable across pages
* Fix belongs_to, has_one and polymorphic index cells raising `Madmin::MissingResource` for a target with no resource. They now go through `associated_resource_for` and render the same missing-resource notice the show partials already do, so one unresolvable row no longer 500s the whole index #367
* Raise `Madmin::MissingRoute` with the route to add when a resource's routes aren't drawn, instead of a `NoMethodError` for the undefined path helper
* Association fields render the record's name without a link when the associated resource has no show route, and belongs_to / has_many selects skip remote search when it has no index route
* Resource names in the menu, headings and buttons use the model's `activerecord.models` translation when it has one. Adds `Resource.friendly_plural_name`; customized views can replace `resource.friendly_name.pluralize` with it to get translated plurals
* Fix JSON fields saving the submitted text as a string instead of parsing it, and showing a Ruby hash instead of JSON on the form and show page. Invalid JSON re-renders the form with a validation error and a blank field saves `nil`. Adds `Field#cast` for fields that convert their submitted value and `Field#accepts?` to reject it with a validation error #301
* Fix `Madmin.resource_by_name` raising `NameError` instead of `Madmin::MissingResource`
* Fix attachment fields raising on show and edit pages when the `ActiveStorage::AttachmentResource` or its routes have been removed. The remove link is now only rendered when the attachment can be deleted through Madmin. Adds `Resource.route?(action)`
* `Madmin.resource_for` now falls back to the resource that declares the object's class with `model`, so a resource named differently from its model (`ArticleResource` for `Blog::Post`) resolves in association cells and form selects without a name-matching alias subclass. `Madmin.resource_by_name` has the same fallback, and both also match a subclass of the declared model. Name-derived and STI lookups still win; two differently-named resources declaring the same model raise `MissingResource` with both names rather than guessing

### 2.6.0

* Add read-only resource support. Override `readonly?` on a resource to redirect write actions back to the index and hide the New/Edit/Delete links #348
* Add extension seams and guards for non-ActiveRecord models: `Resource.model_column_names`, a `paginate_collection` seam in `ResourceController`, skip reorder when there's no sort column, and `respond_to?` guards around `reflections`, `stored_attributes`, `attribute_types`, and `inheritance_column` #352
* Add Greek (el) locale #354
* Add Korean (ko) locale #342
* Fix double bottom border on empty index tables #353

### 2.5.1

* Align index row actions on a single row #351

### 2.5.0

* Add `collection: true` option to `member_action` to also render the action in each row on the index page
* Fix `member_actions` being overwritten with `scopes` on subclassed resources
* Add `ActiveSupport` load hooks for extending Madmin: `:madmin_resource`, `:madmin_field`, `:madmin_search`, `:madmin_base_controller`, and `:madmin_resource_controller`

### 2.4.0

* Add `collection_action` for resources
* Remove unused `propshaft` dependency. Madmin uses the Rails app's asset pipeline which could be propshaft or sprockets.

### 2.3.3

* Fix `new:` and `edit:` options setting. Fixes #332

### 2.3.2

- Support plural module names #313

### 2.3.1

- Fix Trix import for apps not using `action_text-trix`
- Add and require `stimulus-rails`  and `turbo-rails` dependencies

### 2.3.0

- Add support for Lexxy
- Refactor Trix to be detected and included if found
- Import activestorage JavaScript by default
- Automatically add main Rails app's madmin Stimulus controllers

### 2.2.1

- Automatically add engines to resource locations and load path
- Quote table name correctly in search. Fixes #308

### 2.2.0

- Add `Madmin.resource_locations` configuration
  This allows you to specify other directories for finding resources in your application.

### 2.1.3

- Pass `params` instead of `query` to Pagy v43 for has_many fields

### 2.1.2

- Fix pagy v43.0.2 compatibility
- Remove deprecated `mb_chars` usage in search
- Improve button affordances by updating cursor behavior (pointer on hover, not-allowed when disabled) [@anthony0030]
- Fix `root_url` link in navbar if app doesn't have a root

### 2.1.1

- Fix STI fallback resource lookup #295
- Fix overflow scroll on main element
- Preload more than the currently selected value #296
- Singularlize resource names for buttons #294

### 2.1.0

- Add support for Pagy `~> 43.0.0.rc1`

### 2.0.5

- Safely handle missing resources and provide instructions on how to fix them.
- Fix flash messages with layout

### 2.0.4

- Fix sorting with search queries #277

### 2.0.3

- Improve warning when an attribute type can't be inferred

### 2.0.2

- Use `try` so field doesn't raise error when retrieving invalid values
- Don't cast model on find. Let ActiveRecord handle STI.

### 2.0.1

- Add pagination to has_many and nested_has_many fields
- Resource generator now matches the madmin namespace with customizations
  For example: `namespace :madmin, path: :admin do`
- Safely handle missing `config/routes/madmin.rb` for Rails 6.1+
  If this file does not exist, `config/routes.rb` will be used
- Replace flatpickr with date and datetime fields for better accessibility

### 2.0.0

- Remove Tailwind CDN
- Add styles through asset pipeline
- Refactor JavaScript into an Import map (separate from the Rails app)
- Include Rails route helpers in Madmin controllers and views for better integration with the main app
- Add `menu` to resources to allow customizing navigation sort order and add headers for grouping

```ruby
# config/initializers/madmin.rb

# Add a Payments header at the first position in the menu
Madmin.menu.add label: "Payments", position: 0
```

```ruby
class SubscriptionResource < Madmin::Resource
  # Add Subscriptions under the Payments header
  menu parent: "Payments"
end
```

- `member_action` now yields the record to the block

```ruby
class UserResource < Madmin::Resource
  member_action do |user|
    button_to "Impersonate", impersonate_user_path(user)
  end
end
```

### 1.2.10

- Fix compatibility with Pagy 8.x

### 1.2.9

- Fix enum and constant lookup

### 1.2.8

- Relax pagy version dependency - @excid3
- Fix unpermitted params on search - @excid3

### 1.2.7

- Fix importmaps for JS - @excid3

### 1.2.6

- Use stimulus-flatpickr beta 3

### 1.2.5

- Add `Madmin::Fields::File` type for Shrine, Carrierwave, etc - @excid3
- Support isolated namespace models - @excid3
- Use `polymorphic_path` for generating URLs - @excid3
- Automatically link `id` column to show action - @excid3
- Add `Edit` link to index - @excid3
- Fix install generator by adding an ApplicationController to the gem - @excid3

### 1.2.4

- Fix controller inheritance for Rails 6 by making it explicit - @excid3

### 1.2.3

- Upgraded to Stimulus 3.0 - @excid3
- Fix nested forms - @excid3
- Add scrollbar on index for wide tables - @jacobdaddario

### 1.2.2

- Rails 7 support 🚀 - @excid3
- Add support for store_accessors - @jacobdaddario

### 1.2.1

- Handle records not having `created_at` columns when setting the default_sort column - @afomera / @excid3
- Reset page on search submit - @jitingcn
- Catch Pagy overflow errors - @excid3
- Add custom field support - @excid3
- Refactor `Resource.attributes` from an array to hash for faster lookup - @excid3

### 1.2.0

- Allow users to override default sort column and direction on resources
- Add sortable columns on the index for resources
- Don't include `form: false` fields from nested resources in nested resource field params

# 1.1.0

- Add `has_secure_password` support
- Add `madmin:views:javascript` generator
- Fix `madmin:views` generator to copy all templates

# 1.0.2

- Use unpkg for assets instead of skypack. Skypack was missing slimselect css
- Check if Rails UJS is loaded before starting it

# 1.0.1

- Fix belongs_to when nil - @excid3
- Improve support for enums - @excid3

### 1.0.0

- Add view generators - @esmale
- Releasing 1.0.0 to prevent confusion - @excid3

### 1.0.0.beta2

- Ignore autogenerated HABTM models - @excid3

### 1.0.0.beta1

- Use Skypack for CSS & JS - @excid
- Add support for all the Postgres, MySQL, and SQLite types supported by Rails - @excid3
- Add decimal support - @excid3
- Add HABTM example - @excid3
- Added `scope` support to Resources and filtering on index page - @excid3

### 0.1.1

- Open sourced for the first time

### 0.1.0

- Registering the gem
