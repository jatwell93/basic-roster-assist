#!/bin/bash
cd /c/Users/josha/basic-roster-assist

bd create "Build BaseShift UI and Management" \
  --description="Add UI for creating, editing, and deleting BaseShifts within roster templates. Implementation includes: 1) Create BaseShiftsController with RESTful CRUD actions (new, create, edit, update, destroy), 2) Add nested routes under rosters resource, 3) Create form partial for shift with day selector (enum), shift_type selector (enum), start_time and end_time inputs, 4) Add inline form to rosters/show.html.erb for quick shift creation, 5) Add edit/delete buttons on each shift card, 6) Validation feedback for overlapping shifts (leverage model validation), 7) Write comprehensive tests for controller and views. Estimated work: 3-4 hours." \
  -t feature \
  -p 2 \
  --json
