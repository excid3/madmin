import { Controller } from "@hotwired/stimulus"

const INPUT_TYPES = { string: "text", number: "number", date: "date", datetime: "datetime-local", boolean: "text" }
const WITHOUT_VALUE = ["blank", "present", "true", "false"]

// Adds and removes index filter rows, and matches each row's operators and
// value input to the type of the chosen column
export default class extends Controller {
  static targets = ["rows", "template"]
  static values = { operators: Object }

  add() {
    this.rowsTarget.append(this.templateTarget.content.cloneNode(true))
    this.rowsTarget.lastElementChild.querySelector("select").focus()
  }

  remove(event) {
    event.target.closest("[data-filter-row]").remove()
  }

  changeColumn(event) {
    const row = event.target.closest("[data-filter-row]")
    const type = event.target.selectedOptions[0].dataset.filterType
    const operator = row.querySelector("[name='filters[][operator]']")
    const value = row.querySelector("[name='filters[][value]']")

    operator.replaceChildren(...this.operatorsValue[type].map(([label, name]) => new Option(label, name)))
    value.type = INPUT_TYPES[type]
    value.step = type == "number" ? "any" : ""
    value.value = ""
    this.changeOperator({ target: operator })
  }

  changeOperator(event) {
    const row = event.target.closest("[data-filter-row]")
    row.querySelector("[name='filters[][value]']").hidden = WITHOUT_VALUE.includes(event.target.value)
  }
}
