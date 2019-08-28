Feature: Curation workflow test using RSNA

  Scenario: open posda in testing browser
    Given posda is running
    When we open posda
    Then we should see POSDA

  Scenario: create activity
    Given posda is running
    And Your browser is allowing popups
    When we open dbif
      And we click activity
      And we count the existing activities
      And we create an activity
    Then one new activity should exist in dropdown

  Scenario: create activity timepoint
    Given RSNA data was imported under the name "RSNA"
      And an activity exists
      And Your browser is allowing popups
    When we open dbif
      And we click activity
      And we count the existing activities
      And we select an activity
      And we select ActivityOperations
      And we click Create Activity Timepoint from Import Name
      And we input the required parameters, Expand, and Start Subprocess
    Then we recieve an inbox notice of success
