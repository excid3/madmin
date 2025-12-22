pin "application", to: "madmin/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"

pin "trix" if defined?(::Trix) || Rails.gem_version < Gem::Version.new("8.1.0.beta1")
pin "lexxy", to: "lexxy.js" if defined?(::Lexxy)

pin_all_from Madmin::Engine.root.join("app/javascript/madmin/controllers"), under: "controllers", to: "madmin/controllers"
pin_all_from Rails.root.join("app/javascript/madmin/controllers"), under: "controllers", to: "madmin/controllers"

pin "tom-select", to: "https://ga.jspm.io/npm:tom-select@2.4.1/dist/js/tom-select.complete.js"
pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@6.1.2/dist/tailwindcss-stimulus-components.module.js"
