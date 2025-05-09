import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  connect() {
    this.handleEscape = this.handleEscape.bind(this)
  }

  toggle() {
    const isOpen = this.menuTarget.classList.toggle("is-open")
    this.element.setAttribute("aria-expanded", isOpen)
    this.toggleOverlay(isOpen)
    this.toggleBodyScroll(isOpen)
    this.toggleEscapeListener(isOpen)
  }

  close() {
    if (this.menuTarget.classList.contains("is-open")) {
      this.toggle()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    this.toggleEscapeListener(false)
    this.toggleBodyScroll(false)
  }

  toggleOverlay(isOpen) {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle("is-active", isOpen)
    }
  }

  toggleBodyScroll(isOpen) {
    document.body.style.overflow = isOpen ? 'hidden' : ''
  }

  toggleEscapeListener(isOpen) {
    const method = isOpen ? 'addEventListener' : 'removeEventListener'
    document[method]("keydown", this.handleEscape)
  }
}