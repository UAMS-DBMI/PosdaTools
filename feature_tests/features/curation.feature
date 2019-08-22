Feature: Curation workflow test using RSNA

  Scenario: open posda in testing browser
    Given posda is running
    When we open posda
    Then we should see POSDA

  Scenario: create activity
    Given posda is running
    When we open dbif
      And we click activity
      And we count the existing activities
      And we create an activity
    Then one new activity should exist in dropdown
