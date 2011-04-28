Feature: New EEMs
  In order to create a new EEM 
  As a selector
  I want to select an item to collect
  
  Scenario: Widget Exists
    Given I am on the widget
    Then I should see a "label" with text "Found on this site:" 
    Then I should see a text input field for "eem_sourceUrl"
    Then I should see a "dt" with text "Language:" 
    Then I should see a select box for "eem_language"
    Then I should see a "label" with text "Title of work:" 
    Then I should see a text input field for "eem_title"
    Then I should see a "label" with text "Created by:" 
    Then I should see a text input field for "eem_creatorName"
    Then I should see a select box for "eem_creatorType"
    Then I should see a "label" with text "Direct link to PDF:" 
    Then I should see a text input field for "contentUrl"
    Then I should see a text input field for "eem_note"
    Then I should see a "dt" with text "Copyright:" 
    Then I should see a select box for "eem_copyrightStatus"
    Then I should see a "dt" with text "Purchase:" 
    Then I should see a select box for "eem_paymentType"
    Then I should see a text input field for "eem_payment_fund"

  Scenario: Upload Confirmation
    Given I am on the widget
    When I fill in "https://dlib.stanford.edu:6521/text/temp/SampleEEMs" for "eem_sourceUrl" 
    And I type in "Proceedings of the Sardine Symposium 2000" for "eem_title" and fire event "onchange"
    And I fill in "Cucumber, Tester" for "eem_creatorName"  
    And I type in "https://dlib.stanford.edu:6521/text/temp/SampleEEMs/pdf/sardine1.pdf" for "contentUrl" and fire event "onhover"
    And I wait for "Save to dashboard" button to be enabled 
    Then "Save to dashboard" button should be enabled 
    
