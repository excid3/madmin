import { Controller } from "@hotwired/stimulus"

// Tracks the checked records on an index page and shows the bulk actions bar.
// "Select all" extends a fully checked page to every record matching the index
export default class extends Controller {
  static targets = ["record", "page", "bar", "count", "all", "selectAll", "submit"]
  static values = { total: Number, confirm: String }

  connect() {
    this.update()
  }

  togglePage() {
    this.recordTargets.forEach(checkbox => checkbox.checked = this.pageTarget.checked)
    this.update()
  }

  selectAll() {
    this.allTarget.disabled = false
    this.update()
  }

  clear() {
    this.recordTargets.forEach(checkbox => checkbox.checked = false)
    this.update()
  }

  update() {
    const checked = this.recordTargets.filter(checkbox => checkbox.checked).length
    const pageChecked = checked > 0 && checked == this.recordTargets.length

    // Unchecking a record leaves "all" for just the checked ones
    if (!pageChecked) this.allTarget.disabled = true
    const count = this.allTarget.disabled ? checked : this.totalValue

    this.pageTarget.checked = pageChecked
    this.pageTarget.indeterminate = checked > 0 && !pageChecked
    this.barTarget.hidden = checked == 0
    this.countTarget.textContent = count
    if (this.hasSelectAllTarget) this.selectAllTarget.hidden = !pageChecked || !this.allTarget.disabled
    this.submitTarget.dataset.turboConfirm = this.confirmValue.replace("%{count}", count)
  }
}
