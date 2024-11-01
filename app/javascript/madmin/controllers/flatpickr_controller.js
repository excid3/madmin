import Flatpickr from 'stimulus-flatpickr'

export default class extends Flatpickr  {

  connect() {
    const appendTo = this.element.dataset.flatpickrAppendTo
      ? document.querySelector(this.element.dataset.flatpickrAppendTo)
      : null

    this.config = {
      appendTo
    }
    super.connect()
  }
}
