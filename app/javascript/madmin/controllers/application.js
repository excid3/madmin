import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

// *** I dont think we need these anymore ************

// import { Dropdown } from "tailwindcss-stimulus-components"
// application.register("dropdown", Dropdown)

// import StimulusFlatpickr from "flatpickr_controller"
// application.register("flatpickr", StimulusFlatpickr)
