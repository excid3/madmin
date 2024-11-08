import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

import Flatpickr from 'stimulus-flatpickr'
application.register('flatpickr', Flatpickr)

eagerLoadControllersFrom("controllers", application)
