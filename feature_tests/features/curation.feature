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
    Given Test data was imported
      And an activity exists
      And Your browser is allowing popups
    When we open dbif
      And we click activity
      And we count the existing activities
      And we select an activity
      And we select Queries
      And we click Search radiobutton
      And We add parameter SeriesByMatchingImportEventsWithEventInfo
      And we click Search button
      And we click foreground
      And we add SeriesByMatchingImportEventsWithEventInfo parameters
      And we click Query
      And we Click CreateActivityTimepointFromSeriesList
      And we input the parameters including the ID of your Activity
      And we Click Expand
      And we Click Start Subprocess
      And we close popup and switch windows
  Scenario: file inbox message
    Given Test data was imported
      And an activity exists
      And Your browser is allowing popups
    When we open dbif
      And we click activity
      And we count the existing activities
      And we select an activity
      And we file the inbox message
      And we click activity
      And we select Timeline
    Then we see a timeline message with correct file count
