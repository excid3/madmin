import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { confirm: Object }

  connect() {
    this.update()
  }

  update() {
    const count = Array.from(this.element.elements).filter((element) => element.name === "ids[]" && element.checked).length
    const message = count === 1 ? this.confirmValue.one : this.confirmValue.other

    this.element.hidden = count === 0
    this.element.dataset.turboConfirm = message.replace("%{count}", count)
  }
}
