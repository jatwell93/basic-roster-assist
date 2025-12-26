import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shift"]

  connect() {
    console.log("Calendar controller connected")
  }

  // Handle clicking on a shift slot
  shiftTargetConnected(element) {
    element.addEventListener("click", this.handleShiftClick.bind(this))
  }

  handleShiftClick(event) {
    const shiftElement = event.currentTarget
    const hasShifts = shiftElement.querySelector('.bg-blue-100') !== null

    if (hasShifts) {
      // Show shift details or assignment options
      console.log("Shift clicked - has existing shifts")
      // TODO: Implement shift details modal or assignment interface
    } else {
      // Show staff assignment interface for empty slot
      console.log("Empty slot clicked - show assignment options")
      // TODO: Implement staff assignment interface
    }
  }

  // Method to refresh calendar data (can be called after assignments)
  refresh() {
    // TODO: Implement calendar refresh logic
    console.log("Refreshing calendar")
  }
}