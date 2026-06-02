# Resources
Madmin uses Resource classes to add models to the admin area.

## Generate a Resource
To generate a resource for a model, you can run:

rails g madmin:resource ActionText::RichText

## Attribute Options

Each attribute supports visibility options to control where it appears:

| Option        | Description                            |
|---------------|----------------------------------------|
| `index`       | Show on the index (list) page          |
| `show`        | Show on the show (detail) page         |
| `form`        | Show on both new and edit forms        |
| `new`         | Show on the new form                   |
| `edit`        | Show on the edit form                  |
| `label`       | Custom label for the attribute         |
| `description` | Help text displayed with the attribute |
