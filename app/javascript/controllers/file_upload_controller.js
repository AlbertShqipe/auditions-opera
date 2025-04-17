import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
export default class extends Controller {
  static targets = ["cvInput", "cvLabel", "imageInput", "imageLabel", "form"];

  connect() {
    console.log("FileUploadController connected");
    // Select elements
    const form = document.querySelector('.form');
    console.log(form);
    const fields = [
      { id: 'audition_application_first_name', errorId: 'firstNameError' },
      { id: 'audition_application_last_name', errorId: 'lastNameError' },
      { id: 'audition_application_date_of_birth_1i', errorId: 'birthdayError' },
      { id: 'audition_application_date_of_birth_2i', errorId: 'birthdayError' },
      { id: 'audition_application_date_of_birth_3i', errorId: 'birthdayError' },
      { id: 'audition_application_nationality', errorId: 'nationalityError' },
      { id: 'audition_application_address', errorId: 'addressError'},
      { id: 'audition_application_height', errorId: 'heightError'},
      { id: 'audition_application_gender', errorId: 'genderError'},
      { id: 'audition_application_video_link', errorId: 'videoError'},
      { id: 'cv-upload', errorId: 'cvError'},
      { id: 'profile-image-upload', errorId: 'imageError'},
    ];

    // Helper to handle validation
    const validateField = (field) => {
      const input = document.getElementById(field.id);
      console.log(input);
      const errorMessage = document.getElementById(field.errorId);
      if (!input || !errorMessage) return;

      // Add input event listener to hide error
      input.addEventListener('input', () => {
        if (input.value) {
          errorMessage.style.display = 'none';
        }
      });

      // Return validation function for form submit
      return () => {
        if (!input.value) {
          errorMessage.style.display = 'block';
          input.focus();
          return false;
        }
        errorMessage.style.display = 'none';
        return true;
      };
    };

    // Collect validation functions
    const validators = fields.map(validateField).filter(Boolean);

    // Form submission event
    form.addEventListener('submit', (e) => {
      const isValid = validators.every((validate) => validate());
      if (!isValid) e.preventDefault();
    });
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
