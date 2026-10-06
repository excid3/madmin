import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    for (const element of this.element.form.elements) {
      if (element.type === "checkbox") {
        element.checked = this.element.checked
      }
    }
  }
}
