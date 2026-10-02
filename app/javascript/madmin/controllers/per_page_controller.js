import { Controller } from "@hotwired/stimulus"

// Submits the page size form when a size is picked
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
