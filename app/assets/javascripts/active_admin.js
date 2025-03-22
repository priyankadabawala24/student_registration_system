//= require active_admin/base
document.addEventListener("DOMContentLoaded", function() {
    let importButton = document.getElementById("import-csv-button");
    let fileInput = document.getElementById("import-csv-file");
  
    if (importButton && fileInput) {
      importButton.addEventListener("click", function() {
        fileInput.click(); // Open file chooser
      });
  
      fileInput.addEventListener("change", function() {
        if (fileInput.files.length > 0) {
          let formData = new FormData();
          formData.append("file", fileInput.files[0]);
  
          fetch(fileInput.dataset.url, {
            method: "POST",
            body: formData,
            headers: {
              "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
            }
          })
          .then(response => response.json())
          .then(data => {
            alert(data.message); // Show success or error message
            location.reload(); // Refresh page
          })
          .catch(error => {
            alert("Error importing students.");
            console.error(error);
          });
        }
      });
    }
  });
  
  