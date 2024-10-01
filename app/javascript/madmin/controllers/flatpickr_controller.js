import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static values = {
    enableTime: false
  }

  connect() {
    this.flatpickr = flatpickr(this.element, {
      enableTime: this.enableTimeValue
    })
  }

  disconnect() {
    this.flatpickr.destroy()
  }
}
