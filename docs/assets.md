## Adding CSS From Your Rails Application

Madmin exposes an attribute `Madmin.stylesheets` which is an Array of stylesheet names. The default 
value of this attribute is simply the stock `madmin/application` CSS stylesheet.

```ruby
Madmin.stylesheets << "my_stylesheet"
```
The above will include `app/assets/stylesheets/my_stylesheet.css` from your Rails app in the Madmin layout.

## Adding CSS From A Gem

If you need to add custom stylesheets to, for example, include the CSS stylesheet for Hotwire 
Combobox you can do so in an initializer like so:

```ruby
Madmin.stylesheets << "hotwire_combobox"
```
The above will include `app/assets/stylesheets/hotwire_combobox` in the Madmin layout.

## Adding JavaScript From Your Rails Application

If you need to add a package you can do so by accessing `Madmin.importmap.draw` passing in the file
containing your importmap line. For example, to add the Hotwire Combobox importmap, you can do so in your
Madmin initializer like so:

```ruby
Madmin.importmap.draw HotwireCombobox::Engine.root.join("config/hw_importmap.rb")
```

## Complete Asset Override

To fully customize all assets, you can create the following file in your Rails application
`app/views/madmin/_javascript.html.erb`, adding the `javascript_importmap_tags` and `stylesheet_link_tag`
you need.
