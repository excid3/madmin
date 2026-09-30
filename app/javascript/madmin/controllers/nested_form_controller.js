import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return [ "links", "template" ]
  }

  connect() {
    this.wrapperClass = this.data.get("wrapperClass") || "nested-fields"
    // A has_one only allows one record, so the add link hides while it has one
    this.single = this.data.get("single") == "true"
  }

  add_association(event) {
    event.preventDefault()

    var content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.linksTarget.insertAdjacentHTML('beforebegin', content)
    if (this.single) this.linksTarget.hidden = true
  }

  remove_association(event) {
    event.preventDefault()

    let wrapper = event.target.closest("." + this.wrapperClass)

    // New records are simply removed from the page
    if (wrapper.dataset.newRecord == "true") {
      wrapper.remove()

      // Existing records are hidden and flagged for deletion
    } else {
      wrapper.querySelector("input[name*='_destroy']").value = 1
      wrapper.style.display = 'none'
    }

    if (this.single) this.linksTarget.hidden = false
  }
}
