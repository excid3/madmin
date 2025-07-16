import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  connect() {
    this.handleEscape = this.handleEscape.bind(this)
  }

  toggle() {
    const open = this.menuTarget.classList.toggle("open")
    this.element.setAttribute("aria-expanded", open)
    this.toggleOverlay(open)
    this.toggleBodyScroll(open)
    this.toggleEscapeListener(open)
  }

  close() {
    if (this.menuTarget.classList.contains("open")) {
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
    this.close()
  }

  toggleOverlay(open) {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle("is-active", open)
    }
  }

  toggleBodyScroll(open) {
    document.body.style.overflow = open ? 'hidden' : ''
  }

  toggleEscapeListener(open) {
    const method = open ? 'addEventListener' : 'removeEventListener'
    document[method]("keydown", this.handleEscape)
  }
}
