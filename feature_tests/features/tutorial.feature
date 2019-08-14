Feature: Open posda
  Scenario: open posda in testing browser
    Given posda is running
    When we open posda
    Then we should see POSDA

  Scenario: open dbif
    Given posda is running
    When we open posda
      And we click "Posda Login"
      And we log in
    Then we should see DbIf
