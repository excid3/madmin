import { Controller } from "@hotwired/stimulus"

// Adds and removes index filter rows. When the column changes, the row gets
// that column's operators and input type from the server-rendered markup
export default class extends Controller {
  static targets = ["rows", "row", "operators"]

  add() {
    this.rowsTarget.append(this.rowTarget.content.cloneNode(true))
    this.rowsTarget.lastElementChild.querySelector("select").focus()
  }

  remove(event) {
    event.target.closest("[data-filter-row]").remove()
  }

  changeColumn(event) {
    const row = event.target.closest("[data-filter-row]")
    const column = event.target.selectedOptions[0]
    const operator = row.querySelector("[name='filters[][operator]']")
    const value = row.querySelector("[name='filters[][value]']")
    const operators = this.operatorsTargets.find(template => template.dataset.filterType == column.dataset.filterType)

    operator.replaceChildren(operators.content.cloneNode(true))
    value.type = column.dataset.inputType
    value.step = value.type == "number" ? "any" : ""
    value.value = ""
    this.changeOperator({ target: operator })
  }

  changeOperator(event) {
    const row = event.target.closest("[data-filter-row]")
    row.querySelector("[name='filters[][value]']").hidden = "withoutValue" in event.target.selectedOptions[0].dataset
  }
}
