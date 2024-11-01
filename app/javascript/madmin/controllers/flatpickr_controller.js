import Flatpickr from 'stimulus-flatpickr'

export default class extends Flatpickr {
  connect() {
    const appendTo = this.element.dataset.flatpickrAppendTo
      ? document.querySelector(this.element.dataset.flatpickrAppendTo)
      : null

    this.config = {
      appendTo
    }
    super.connect()
  }

  close() {
    // to work inside dropdowns
    const filterButton = this.element.closest('.dropdown')?.querySelector('label')
    filterButton?.focus()
  }
}
