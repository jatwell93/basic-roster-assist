import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["shift", "staffModal", "shiftModal", "timeInputs", "breakInputs"]
  static values = { rosterId: Number }

  connect() {
    this.initializeShiftHandlers()
  }

  // Initialize click handlers for all shift cells
  initializeShiftHandlers() {
    this.shiftTargets.forEach((element) => {
      element.addEventListener("click", this.handleShiftClick.bind(this))
    })
  }

  // Handle clicking on a shift slot
  handleShiftClick(event) {
    if (event.target.closest(".shift-actions")) return // Ignore action button clicks

    const cell = event.currentTarget
    const day = cell.dataset.day
    const hour = cell.dataset.hour
    const shiftId = cell.dataset.shiftId

    if (shiftId) {
      // Show shift details/edit modal
      this.showShiftDetails(shiftId, day, hour)
    } else {
      // Show staff assignment modal
      this.showStaffModal(day, hour)
    }
  }

  // Open staff assignment modal
  async showStaffModal(day, hour) {
    this.currentSlot = { day, hour }
    await this.fetchAvailableStaff()
    this.showModal("staffModal")
  }

  // Fetch available staff from server
  async fetchAvailableStaff() {
    try {
      const response = await fetch(
        `/rosters/${this.rosterIdValue}/available_staff.json`
      )
      const data = await response.json()
      this.renderStaffList(data)
    } catch (error) {
      console.error("Failed to load staff:", error)
      alert("Could not load available staff. Please refresh and try again.")
    }
  }

  // Render staff list in modal
  renderStaffList(staff) {
    const container = this.staffModalTarget.querySelector("[data-staff-list]")
    container.innerHTML = staff
      .map((person) => {
        return `
        <div class="p-3 border rounded hover:bg-blue-50 cursor-pointer" data-staff-id="${person.id}">
          <div class="font-medium text-gray-900">${person.name}</div>
          <div class="text-sm text-gray-500">${person.email}</div>
        </div>
      `
      })
      .join("")

    // Add click handlers to staff items
    container.querySelectorAll("[data-staff-id]").forEach((item) => {
      item.addEventListener("click", (e) => {
        const staffId = e.currentTarget.dataset.staffId
        this.selectStaffAndShowTimeInputs(staffId)
      })
    })
  }

  // Move to time/break input after staff selection
  selectStaffAndShowTimeInputs(staffId) {
    this.currentSlot.staffId = staffId
    // Hide staff list, show time inputs in same modal
    document.querySelector("[data-staff-list]").classList.add("hidden")
    this.timeInputsTarget.classList.remove("hidden")
  }

  // Save new shift
  async saveNewShift() {
    const startTime = document.querySelector(
      "[name=start_time]"
    ).value
    const endTime = document.querySelector("[name=end_time]").value
    const breakStart = document.querySelector(
      "[name=break_start_time]"
    ).value
    const breakEnd = document.querySelector("[name=break_end_time]").value

    if (!startTime || !endTime) {
      alert("Please enter start and end times")
      return
    }

    try {
      const response = await fetch(
        `/rosters/${this.rosterIdValue}/shifts`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.getCsrfToken(),
          },
          body: JSON.stringify({
            shift: {
              day_of_week: this.currentSlot.day,
              start_time: startTime,
              end_time: endTime,
              break_start_time: breakStart || null,
              break_end_time: breakEnd || null,
              assigned_staff_id: this.currentSlot.staffId,
            },
          }),
        }
      )

      if (!response.ok) {
        const error = await response.json()
        alert(`Error: ${error.error}`)
        return
      }

      this.closeModals()
      this.refreshCalendar()
    } catch (error) {
      console.error("Failed to save shift:", error)
      alert("Could not save shift. Please try again.")
    }
  }

  // Show shift details modal
  async showShiftDetails(shiftId, day, hour) {
    // In full implementation, would fetch shift details and show edit/delete options
    console.log(`Show details for shift ${shiftId}`)
  }

  // Delete shift
  async deleteShift(shiftId) {
    if (!confirm("Are you sure you want to delete this shift?")) return

    try {
      const response = await fetch(
        `/rosters/${this.rosterIdValue}/shifts/${shiftId}`,
        {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": this.getCsrfToken(),
          },
        }
      )

      if (!response.ok) {
        throw new Error("Failed to delete shift")
      }

      this.refreshCalendar()
    } catch (error) {
      console.error("Failed to delete shift:", error)
      alert("Could not delete shift. Please try again.")
    }
  }

  // Finalize roster and send emails
  async finalizeRoster() {
    if (
      !confirm(
        "Are you sure? This will send shift notifications to all team members."
      )
    )
      return

    try {
      const response = await fetch(
        `/rosters/${this.rosterIdValue}/finalize`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.getCsrfToken(),
          },
        }
      )

      if (!response.ok) {
        throw new Error("Failed to finalize roster")
      }

      const result = await response.json()
      alert(`Roster finalized! ${result.message}`)
      this.refreshCalendar()
    } catch (error) {
      console.error("Failed to finalize:", error)
      alert("Could not finalize roster. Please try again.")
    }
  }

  // Refresh calendar view
  async refreshCalendar() {
    window.location.reload()
  }

  // Modal helpers
  showModal(target) {
    this[`${target}Target`].classList.remove("hidden")
  }

  closeModals() {
    this.staffModalTarget?.classList.add("hidden")
    this.shiftModalTarget?.classList.add("hidden")
    // Reset modal state
    document.querySelector("[data-staff-list]")?.classList.remove("hidden")
    this.timeInputsTarget?.classList.add("hidden")
  }

  // Get CSRF token from document
  getCsrfToken() {
    const token = document.querySelector(
      'meta[name="csrf-token"]'
    )
    return token ? token.content : ""
  }
}