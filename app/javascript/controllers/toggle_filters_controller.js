import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-filters"
export default class extends Controller {
  connect() {
    const btnFilters = document.getElementById("btn-filter");
    console.log(btnFilters);
    btnFilters.addEventListener("click", () => {
      const filters = document.querySelector(".main-filters");
      const btnClear = document.querySelector(".btn-clear");
      filters.classList.toggle("hidden");
      btnClear.classList.toggle("hidden");
    });
  }
}
