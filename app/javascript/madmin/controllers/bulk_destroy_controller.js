import { Controller } from "@hotwired/stimulus"

// Shows the "Delete selected" button while any record is checked
export default class extends Controller {
  static targets = [ "form", "checkbox" ]

  toggleAll(event) {
    this.checkboxTargets.forEach((checkbox) => checkbox.checked = event.target.checked)
    this.update()
  }

  update() {
    this.formTarget.hidden = !this.checkboxTargets.some((checkbox) => checkbox.checked)
  }
}
