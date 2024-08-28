pin "application-madmin", to: "madmin/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin_all_from Madmin::Engine.root.join("app/javascript/madmin/controllers"), under: "controllers", to: "madmin/controllers"

pin "tom-select", to: "https://unpkg.com/tom-select@2/dist/esm/tom-select.complete.js"
pin "tailwindcss-stimulus-components", to: "https://unpkg.com/tailwindcss-stimulus-components@5/dist/tailwindcss-stimulus-components.module.js"
pin "flatpickr", to: "https://unpkg.com/flatpickr@4/dist/esm/index.js"
pin "stimulus-flatpickr", to: "https://unpkg.com/stimulus-flatpickr@3.0.0-0/dist/index.m.js"
