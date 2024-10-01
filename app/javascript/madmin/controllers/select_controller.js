import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    options: Object,
    url: String
  }

  connect() {
    this.select = new TomSelect(this.element, {
      plugins: ['remove_button'],
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      load: (search, callback) => {
        let url = search ? `${this.urlValue}?q=${search}` : this.urlValue;
        fetch(url)
          .then(response => response.json())
          .then(json => {
            callback(json);
          }).catch(() => {
            callback();
          });
      }
    })
  }

  disconnect() {
    this.select.destroy()
  }
}
