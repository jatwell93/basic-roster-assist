## ADDED Requirements

### Requirement: Base Roster Management
Admins SHALL be able to create and edit a perpetual "Base Roster" that serves as a template.

#### Scenario: Create Base Roster
- **WHEN** an admin defines shifts for a standard week or fortnight for rotating rosters (users may work 6 days one week then 4 the next)
- **THEN** the system saves this as the Base Roster

### Requirement: Weekly Roster Generation
The system SHALL allow generating specific weekly rosters from the Base Roster.

#### Scenario: Generate Weekly Roster
- **WHEN** an admin selects a week and clicks "Generate from Base"
- **THEN** a new editable roster for that week is created with shifts copied from the Base Roster

### Requirement: Roster Adjustment
Managers SHALL be able to add, remove, or modify shifts in a weekly roster.

#### Scenario: Add Casual Shift
- **WHEN** a manager adds a shift to a weekly roster
- **THEN** the shift is saved and the projected wage cost is updated

# CURRENT BEHAVIOUR
- **WHEN** Admin user attempts to create a new roster (rosters/new route) User receives an error:
  
`ActionView::Template::Error (undefined method 'base_rosters_path' for an instance of #<Class:0x000002a191093c08>)
Caused by: NoMethodError (undefined method 'base_rosters_path' for an instance of #<Class:0x000002a191093c08>)

Information for: ActionView::Template::Error (undefined method 'base_rosters_path' for an instance of #<Class:0x000002a191093c08>):
     5:       <p class="text-sm text-gray-600 mb-6">Set up a new roster schedule with shifts and team assignments</p>
     6: 
     7:       <%= form_with model: @roster, class: "space-y-6" do |form| %>
     8:         <% if @roster.errors.any? %>
     9:           <div class="rounded-md bg-red-50 p-4">
    10:             <h3 class="text-sm font-medium text-red-800">
    11:               <%= pluralize(@roster.errors.count, "error") %> prevented this roster from being saved:
  
app/views/rosters/new.html.erb:8

Information for cause: NoMethodError (undefined method 'base_rosters_path' for an instance of #<Class:0x000002a191093c08>):
  
app/views/rosters/new.html.erb:8`

