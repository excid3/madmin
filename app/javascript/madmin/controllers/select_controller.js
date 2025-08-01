import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    options: Object,
    url: String
  }

  connect() {
    let options = {
      plugins: ['remove_button'],
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
    }

    if (this.hasUrlValue) {
      options["load"] = (search, callback) => {
        let url = search ? `${this.urlValue}?q=${search}` : this.urlValue;
        fetch(url)
          .then(response => response.json())
          .then(json => {
            callback(json);
          }).catch(() => {
            callback();
          });
      }
    }

    this.select = new TomSelect(this.element, options)
  }

  disconnect() {
    this.select.destroy()
  }
}
