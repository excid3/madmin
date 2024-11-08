import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["conditionGroups", "filterButton"]
  static values = {
    initialFilters: String
  }

  connect() {
    this.constructForm()
    // Only add initial group if none exist
    if (this.conditionGroupsTarget.children.length === 0) {
      this.addNewGroupWithCondition()
    }
  }

  disconnect() {
    // clear filters to prevent caching
    this.conditionGroupsTarget.innerHTML = ''
  }

  constructForm() {
    // Reconstruct filters from params
    const filters = JSON.parse(this.initialFiltersValue)
    if (!filters.groups) return

    Object.entries(filters.groups).forEach(([groupId, group]) => {
      let groupElement = this.addConditionGroup(groupId)
      groupElement.querySelector('.select-match-type').value = group.match_type

      if (!group.conditions) return
      Object.entries(group.conditions).forEach(([conditionId, condition]) => {
        let el = this.addCondition({ params: { groupId } })
        const columnSelect = el.querySelector('.select-column')
        columnSelect.value = condition.column

        // Trigger the column change to show the correct input
        this.handleColumnChange({ target: columnSelect })

        el.querySelector('.select-operator').value = condition.operator
        el.querySelector('.select-value:not(.hidden)').value = condition.value
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

  handleColumnChange(event) {
    const column = event.target
    const conditionElement = column.closest('.filter-condition')
    const filterType = column.selectedOptions[0].dataset.filterType
    const inputTypeClass = `input-type-${filterType || 'text'}`
    const input = conditionElement.querySelector(`.${inputTypeClass}`) || conditionElement.querySelector('.input-type-text')

    conditionElement.querySelectorAll('.select-value').forEach(input => {
      // Skip datetime inputs on mobile devices
      if (input.type === 'datetime-local') {
        input.value = ''
        return
      }

      input.classList.add('hidden')
      input.disabled = true
      input.value = ''
    })

    // Update hidden input to store the type
    const typeInput = conditionElement.querySelector('.select-type')
    typeInput.value = filterType

    // Enable the correct input
    input.classList.remove('hidden')
    input.disabled = false

    // Set default value for boolean type
    if (filterType === 'boolean') {
      input.value = 'true'
    }

    // Handle Flatpickr inputs differently on mobile
    if (input.type === 'hidden' && input.nextElementSibling?.type === 'datetime-local') {
      input.nextElementSibling.classList.remove('hidden')
      input.nextElementSibling.disabled = false
      return
    }
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
