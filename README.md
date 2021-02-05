# Madmin

### 🛠 A robust Admin Interface for Ruby on Rails apps

[![Build Status](https://github.com/excid3/madmin/workflows/Tests/badge.svg)](https://github.com/excid3/madmin/actions) [![Gem Version](https://badge.fury.io/rb/madmin.svg)](https://badge.fury.io/rb/madmin)

Why another Ruby on Rails admin? We wanted an admin that was:

* Familiar and customizable like Rails scaffolds (less DSL)
* Supports all the Rails features out of the box (ActionText, ActionMailbox, etc)
* Stimulus / Turbolinks / Hotwire ready

## Installation
Add `madmin` to your application's Gemfile:

```bash
bundle add madmin
```

Then run the madmin generator:

```bash
rails g madmin:install
```

This will install Madmin and generate resources for each of the models it finds.

## Resources

Madmin uses `Resource` classes to add models to the admin area.

### Generate a Resource

To generate a resource for a model, you can run:

```bash
rails g madmin:resource ActionText::RichText
```

## Configuring Views

The views packaged within the gem are a great starting point, but inevitably people will need to be able to customize those views.

You can use the included generator to create the appropriate view files, which can then be customized.

For example, running the following will copy over all of the views into your application that will be used for every resource:
```bash
rails generate madmin:views
```

If you only need to customize specific views, you can restrict which views are copied by the generator:
```bash
rails g madmin:views:index
 # -> app/views/madmin/application/index.html.erb
```

You can also scope the copied view(s) to a specific Resource/Model:
```bash
rails generate madmin:views:index Book
 # -> app/views/madmin/books/index.html.erb
```

## 🙏 Contributing

This project uses Standard for formatting Ruby code. Please make sure to run standardrb before submitting pull requests.

## 📝 License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
