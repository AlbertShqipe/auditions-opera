import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
export default class extends Controller {
  static targets = ["cvInput", "cvLabel", "imageInput", "imageLabel", "form"];

  connect() {
    console.log("FileUploadController connected");
  }

  updateFileName(event) {
    const input = event.target;
    const label = input.dataset.labelTarget;
    const file = input.files[0];

    const allowedCVTypes = ["application/pdf"];
    const allowedImageTypes = ["image/png", "image/jpeg", "image/gif", "image/jpg", "image/webp"];

    if (file) {
      const fileType = file.type;
      const isCV = input.id === "cv-upload";

      if ((isCV && !allowedCVTypes.includes(fileType)) || (!isCV && !allowedImageTypes.includes(fileType))) {
        alert(`Invalid file type! Please upload a ${isCV ? "PDF" : "JPG, PNG, or GIF"}.`);
        input.value = "";
        this[label + "Target"].textContent = "No file chosen";
        return;
      }

      this[label + "Target"].textContent = file.name;
    } else {
      this[label + "Target"].textContent = "No file chosen";
    }
  }

  validateForm(event) {
    if (!this.formTarget.checkValidity()) {
      event.preventDefault();
      event.stopPropagation();

      // Show alert message
      let alertDiv = document.createElement("div");
      alertDiv.className = "alert alert-danger mt-2";
      alertDiv.innerHTML = "Veuillez remplir tous les champs obligatoires.";
      this.formTarget.prepend(alertDiv);
    }

    this.formTarget.classList.add("was-validated");
  }
}
