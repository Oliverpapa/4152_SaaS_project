Feature: main functionalities for Trapplar: User could customize the traveling plan they picked from our suggestions

  As a potential traveler who searched for traveling plans, I will see several suggestions.
  So that I can pick one suggested traveling plan
  Then I can see that traveling plan in detail and customize it

Background: attraction in database

  Given the following attractions exist:
  | name                  | rating | address                                  |    city    | state |  latitude   | longitude   | recommended_time | open_time  | close_time |
  | Empire State Building | 4.7    | 20 W 34th St., New York, NY 10001        |  New York  |  NY   |  40.7484396 |-73.9944193  | 60               | "09:00:00" | "22:00:00" |
  | The Met               | 4.8    | 1000 5th Ave, New York, NY 10028         |  New York  |  NY   |  40.7794366 |-74.0950799  | 180              | "10:00:00" | "21:00:00" |
  | MoMA                  | 4.6    | 11 W 53rd St, New York, NY 10019         |  New York  |  NY   |  40.7484714 |-73.9944193  | 180              | "10:30:00" | "17:30:00" |
  | Statue of Liberty     | 4.7    | Statue of Liberty, New York, NY 10004    |  Lake City  |  CA   |  40.6917572 |-74.0429902  | 180              | "08:30:00" | "16:00:00" |
  | Columbia University   | 4.7    | Columbia University, New York, NY 10027  |  Lake City  |  CA   |  40.8075395 |-73.9670574  | 60               | "00:00:00" | "00:00:00" |

@javascript
Scenario: User could go to correct traveling detailed page after they picked from our suggestions
  Given I am on the home page
  When I select "NY" from "travel_plan_state"
  And  I select "2" from "travel_plan_days"
  And  I press "Search"
  Then I should be on the suggestion page
  Then I should see "Suggestion: Chill"
  Then I should see "Suggestion: Hustle"
  Then I press "Customize" for "chill suggestion"
  Then I should be on the customize page for "Chill"
  Then I should see "Day 1"
  Then I should see "Day 2"
  Then I should see "Empire State Building"
  Then I should see "The Met"
  Then I should see "MoMA"
  Then I should see "Back to suggestion"

@javascript
Scenario: User should be able to add a stop to the traveling plan
    Given I am on the home page
    When I select "NY" from "travel_plan_state"
    And  I select "1" from "travel_plan_days"
    And  I press "Search"
    And  I press "Customize" for "chill suggestion"
    Then I should see "Add Attraction"
    When I press "add_attraction_0"
    Then I should see "MoMA" in "dropdown_menu_0"
    And  I follow "MoMA"
    Then I should see "Empire State Building"
    Then I should see "The Met"
    Then I should see "MoMA"

@javascript
Scenario: User should be able to remove a stop from the traveling plan
    Given I am at the customize page for the chill suggestion
    Then I should see "The Met"
    Then I should see "MoMA"
    Then I should see "Empire State Building"
    When I close "The Met"
    Then I should not see "The Met"
    Then I should see "MoMA"
    Then I should see "Empire State Building"

@javascript
Scenario: User should be able to go back to the suggestion page
    Given I am at the customize page for the chill suggestion
    When I follow "Back to suggestion"
    Then I should be on the suggestion page

@javascript
Scenario: User should be able to drag attractions to change the order
    Given I am at the customize page for the chill suggestion
    When I drag "Empire State Building" to "The Met"
    Then I should see "The Met" before "Empire State Building"
    Then I should see "Empire State Building" before "MoMA"

@javascript
Scenario: User should be able to change the attraction's duration
    # TODO: very difficult to implement resizing with capybara

@javascript
Scenario: When the user directly go to the customization page, they will be redirect to the home page
    Given I am on the customize page
    Then I should be on the home page
