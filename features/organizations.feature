Feature: Organizations
  In order to administer organizations
  As an admin
  I want to create, delete, edit, organizations
  
  Scenario: Organization List as a simple user
    Given I am logged in as dfaraday with password test
	And I have organizations named Widmore Corporation
    When I go to the list of organizations
    Then I should see "Widmore Corporation"

  Scenario: Organization List as admin
    Given I am logged in as clittleton with password test
	And I have organizations named Widmore Corporation
    When I go to the list of organizations
    Then I should see all the organizations

  # Simple User's view
  Scenario: Simple Users should see only it's organizations

  