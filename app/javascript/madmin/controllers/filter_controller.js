import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["conditionGroups", "filterButton"]
  static values = {
    groupTemplate: String,
    conditionTemplate: String,
    initialFilters: String
  }

  connect() {
    this.constructForm()
    // Only add initial group if none exist
    if (this.conditionGroupsTarget.children.length === 0) {
      this.addNewGroupWithCondition()
    }
  }

  constructForm() {
    // Reconstruct filters from params
    const filters = JSON.parse(this.initialFiltersValue)
    if (!filters.groups) return
    Object.entries(filters.groups).forEach(([groupId, group]) => {
      let groupElement = this.addConditionGroup(groupId)
      groupElement.querySelector('.select-match-type').value = group.match_type
      Object.entries(group.conditions).forEach(([conditionId, condition]) => {
        let el = this.addCondition({ params: { groupId } })
        el.querySelector('.select-column').value = condition.column
        el.querySelector('.select-operator').value = condition.operator
        el.querySelector('input[type="text"]').value = condition.value
      })
    })
  }

  // Actions
  addNewGroupWithCondition() {
    const groupId = this.#generateUniqueId()
    this.addConditionGroup(groupId)
    this.addCondition({ params: { groupId } })
  }

  addCondition({ params: { groupId } }) {
    if (!groupId) return

    const conditionsContainer = document.getElementById(`conditions-${groupId}`)
    if (!conditionsContainer) return

    const conditionId = this.#generateUniqueId()
    const newCondition = this.#buildCondition(groupId, conditionId)
    conditionsContainer.appendChild(newCondition)
    return newCondition
  }

  removeCondition({ event, params: { groupId, conditionId } }) {
    const condition = document.getElementById(`condition-${groupId}-${conditionId}`)
    condition?.remove()
    this.filterButtonTarget.focus()
  }

  addConditionGroup(groupId) {
    const newGroup = this.#buildGroup(groupId)
    this.conditionGroupsTarget.appendChild(newGroup)
    return newGroup
  }

  removeConditionGroup({ params: { groupId } }) {
    const group = document.getElementById(`group-${groupId}`)
    group?.remove()
    this.filterButtonTarget.focus()
  }

  // Private Methods

  #buildGroup(groupId) {
    const template = document.getElementById('condition-group-template')
    const content = template.content.cloneNode(true)
    return this.#replaceIds(content.firstElementChild, 'GROUP_ID', groupId)
  }

  #buildCondition(groupId, conditionId) {
    const template = document.getElementById('condition-template')
    const content = template.content.cloneNode(true)
    const element = content.firstElementChild

    this.#replaceIds(element, 'GROUP_ID', groupId)
    return this.#replaceIds(element, 'CONDITION_ID', conditionId)
  }

  #replaceIds(element, placeholder, id) {
    const regex = new RegExp(placeholder, 'g')
    element.id = element.id.replace(regex, id)
    element.innerHTML = element.innerHTML.replace(regex, id)
    return element
  }

  #generateUniqueId() {
    return crypto?.randomUUID?.() || Math.random().toString(36).slice(2)
  }
}
