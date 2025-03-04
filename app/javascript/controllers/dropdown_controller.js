import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add click event listener to document
    document.addEventListener("click", this.handleDocumentClick.bind(this))
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener("click", this.handleDocumentClick.bind(this))
  }

  toggle(event) {
    // Prevent event from bubbling up
    event.stopPropagation()
    
    // Get the dropdown ID from the clicked button
    const button = event.currentTarget
    const dropdownId = button.dataset.dropdownId
    
    // Find the dropdown element
    const dropdown = document.querySelector(`#${dropdownId}`)
    
    // Close all other dropdowns first
    const allDropdowns = document.querySelectorAll('.dropdown-content')
    allDropdowns.forEach(d => {
      if (d.id !== dropdownId) {
        d.classList.add('hidden')
      }
    })
    
    // Toggle current dropdown
    if (dropdown) {
      dropdown.classList.toggle('hidden')
    }
  }

  handleDocumentClick(event) {
    // Check if click is outside dropdown and button
    const isDropdown = event.target.closest('.dropdown-content')
    const isDropdownButton = event.target.closest('[data-dropdown-id]')
    
    if (!isDropdown && !isDropdownButton) {
      // Close all dropdowns
      const allDropdowns = document.querySelectorAll('.dropdown-content')
      allDropdowns.forEach(dropdown => {
        dropdown.classList.add('hidden')
      })
    }
  }
}