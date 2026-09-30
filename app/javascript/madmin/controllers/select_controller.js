import { Controller } from "@hotwired/stimulus"

let count = 0

// Turns a <select> into a searchable combobox. The <select> stays in the form,
// hidden, and is what gets submitted.
//
// Without a url, the <select>'s own options are filtered as you type.
// With a url, options are loaded from the server when it opens and as you type:
//
//   <select data-controller="select" data-select-url-value="/madmin/users.json">
//
//   GET /madmin/users.json           =>  [{"id": 1, "name": "Chris Oliver"}, ...]
//   GET /madmin/users.json?q=chris   =>  [{"id": 1, "name": "Chris Oliver"}]
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.multiple = this.element.multiple
    this.results = []
    this.activeIndex = -1

    this.build()
    this.element.hidden = true
    this.element.after(this.wrapper)
    this.labelFor(this.element.id)?.setAttribute("for", this.input.id)
    this.render()
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.abortController?.abort()
    this.labelFor(this.input.id)?.setAttribute("for", this.element.id)
    this.wrapper.remove()
    this.element.hidden = false
  }

  // Events

  focus() {
    if (!this.multiple) this.input.select()
    this.search()
  }

  typed() {
    clearTimeout(this.timeout)
    if (this.hasUrlValue) {
      this.timeout = setTimeout(() => this.search(), 300)
    } else {
      this.search()
    }
  }

  keydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.isOpen ? this.moveActive(1) : this.search()
        break
      case "ArrowUp":
        event.preventDefault()
        this.moveActive(-1)
        break
      case "Enter":
        if (this.isOpen && this.results[this.activeIndex]) {
          event.preventDefault()
          this.choose(this.results[this.activeIndex])
        }
        break
      case "Escape":
        if (this.isOpen) {
          event.preventDefault()
          this.close()
        }
        break
      case "Backspace":
        if (this.multiple && this.input.value === "") {
          this.remove(this.selectedOptions.at(-1)?.value)
        }
        break
    }
  }

  blur() {
    // Clearing the text of a single select clears its value
    if (!this.multiple && this.input.value === "" && this.element.value !== "") {
      this.choose({ id: "", name: "" })
    }
    this.close()
  }

  // Searching

  async search() {
    const query = this.query

    if (this.hasUrlValue) {
      this.abortController?.abort()
      this.abortController = new AbortController()

      const url = new URL(this.urlValue, window.location.origin)
      if (query) url.searchParams.set("q", query)

      try {
        const response = await fetch(url, { headers: { Accept: "application/json" }, signal: this.abortController.signal })
        this.open(await response.json())
      } catch (error) {
        if (error.name !== "AbortError") this.open([])
      }
    } else {
      this.open(this.localResults(query))
    }
  }

  localResults(query) {
    return Array.from(this.element.options)
      .filter(option => option.value !== "")
      .map(option => ({ id: option.value, name: option.text }))
      .filter(result => result.name.toLowerCase().includes(query.toLowerCase()))
  }

  // Choosing

  choose({ id, name }) {
    const value = String(id)
    let option = Array.from(this.element.options).find(option => option.value === value)
    if (!option) {
      option = new Option(name, value)
      this.element.add(option)
    }
    option.selected = true
    this.changed()

    if (this.multiple) this.input.value = ""
    this.close()
  }

  remove(value) {
    const option = this.selectedOptions.find(option => option.value === value)
    if (option) {
      option.selected = false
      this.changed()
    }
  }

  changed() {
    this.element.dispatchEvent(new Event("change", { bubbles: true }))
    this.render()
  }

  // Rendering

  build() {
    this.wrapper = document.createElement("div")
    this.wrapper.className = "combobox"

    this.control = document.createElement("div")
    this.control.className = "combobox-control"
    this.control.addEventListener("click", () => this.input.focus())

    this.input = document.createElement("input")
    this.input.type = "text"
    this.input.id = `${this.element.id || `select_${++count}`}_combobox`
    this.input.className = "combobox-input"
    this.input.autocomplete = "off"
    this.input.setAttribute("role", "combobox")
    this.input.setAttribute("aria-autocomplete", "list")
    this.input.setAttribute("aria-expanded", "false")
    this.input.addEventListener("focus", () => this.focus())
    this.input.addEventListener("input", () => this.typed())
    this.input.addEventListener("keydown", event => this.keydown(event))
    this.input.addEventListener("blur", () => this.blur())

    this.listbox = document.createElement("ul")
    this.listbox.id = `${this.input.id}_listbox`
    this.listbox.className = "combobox-listbox"
    this.listbox.hidden = true
    this.listbox.setAttribute("role", "listbox")
    // Keep focus in the input so choosing an option doesn't blur it first
    this.listbox.addEventListener("mousedown", event => event.preventDefault())
    this.input.setAttribute("aria-controls", this.listbox.id)

    this.control.append(this.input)
    this.wrapper.append(this.control, this.listbox)
  }

  render() {
    if (this.multiple) {
      this.control.querySelectorAll(".combobox-chip").forEach(chip => chip.remove())
      this.selectedOptions.forEach(option => this.input.before(this.chip(option)))
    } else {
      const option = this.selectedOptions[0]
      this.input.value = option && option.value !== "" ? option.text : ""
    }
  }

  chip(option) {
    const chip = document.createElement("span")
    chip.className = "combobox-chip"
    chip.textContent = option.text

    const button = document.createElement("button")
    button.type = "button"
    button.textContent = "×"
    button.setAttribute("aria-label", `Remove ${option.text}`)
    button.addEventListener("click", event => {
      event.stopPropagation()
      this.remove(option.value)
    })

    chip.append(button)
    return chip
  }

  open(results) {
    const selected = this.selectedOptions.map(option => option.value)
    this.results = this.multiple ? results.filter(result => !selected.includes(String(result.id))) : results
    this.activeIndex = this.results.length ? 0 : -1

    this.listbox.replaceChildren(...this.results.map((result, index) => {
      const item = document.createElement("li")
      item.id = `${this.listbox.id}_${index}`
      item.textContent = result.name
      item.setAttribute("role", "option")
      item.addEventListener("click", () => this.choose(result))
      return item
    }))

    if (this.results.length === 0) {
      const empty = document.createElement("li")
      empty.className = "combobox-empty"
      empty.textContent = "No results"
      this.listbox.append(empty)
    }

    this.listbox.hidden = false
    this.input.setAttribute("aria-expanded", "true")
    this.highlight()
  }

  close() {
    clearTimeout(this.timeout)
    this.abortController?.abort()
    this.listbox.hidden = true
    this.input.setAttribute("aria-expanded", "false")
    this.input.removeAttribute("aria-activedescendant")
    this.render()
  }

  moveActive(step) {
    if (this.results.length === 0) return
    this.activeIndex = (this.activeIndex + step + this.results.length) % this.results.length
    this.highlight()
  }

  highlight() {
    this.listbox.querySelectorAll("[role=option]").forEach((item, index) => {
      const active = index === this.activeIndex
      item.setAttribute("aria-selected", active)
      if (active) {
        this.input.setAttribute("aria-activedescendant", item.id)
        item.scrollIntoView({ block: "nearest" })
      }
    })
  }

  // Helpers

  get query() {
    return this.multiple || this.input.value !== this.selectedOptions[0]?.text ? this.input.value.trim() : ""
  }

  get isOpen() {
    return !this.listbox.hidden
  }

  get selectedOptions() {
    return Array.from(this.element.selectedOptions).filter(option => option.value !== "")
  }

  labelFor(id) {
    return id ? document.querySelector(`label[for="${CSS.escape(id)}"]`) : null
  }
}
