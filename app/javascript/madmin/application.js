import "@hotwired/turbo-rails"
import "@rails/actiontext"
import * as ActiveStorage from "@rails/activestorage"
import "controllers"

// Uploads files straight to storage for fields with `direct_upload: true`. Other file fields submit with the form
ActiveStorage.start()
