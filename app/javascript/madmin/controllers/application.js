import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import { Dropdown } from "tailwindcss-stimulus-components"
application.register("dropdown", Dropdown)

import StimulusFlatpickr from "stimulus-flatpickr"
application.register("flatpickr", StimulusFlatpickr)
