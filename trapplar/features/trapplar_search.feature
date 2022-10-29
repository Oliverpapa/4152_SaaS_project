Feature: basic functionalities for Trapplar: User could search for traveling plans with requirements and see our results

  As a potential traveler
  So that I can search for traveling suggestions with destination(state), stops(cities), and number of traveling days
  Then I can see suggested traveling plans

Background: attraction in database

  Given the following attractions exist:
  | name                  | rating | address                                  |    city    | state |  latitude   | longitude   | recommended_time | open_time | close_time |
  | Empire State Building | 4.7    | 20 W 34th St., New York, NY 10001        |  New York  |  NY   |  40.7484396 |-73.9944193  | 60               | 0900      | 2200       |
  | The Met               | 4.8    | 1000 5th Ave, New York, NY 10028         |  New York  |  NY   |  40.7794366 |-74.0950799  | 180              | 1000      | 2100       |
  | MoMA                  | 4.6    | 11 W 53rd St, New York, NY 10019         |  New York  |  NY   |  40.7484714 |-73.9944193  | 180              | 1030      | 1730       |
  | Statue of Liberty     | 4.7    | Statue of Liberty, New York, NY 10004    |  New York  |  NY   |  40.6917572 |-74.0429902  | 180              | 0830      | 1600       |
  | Columbia University   | 4.7    | Columbia University, New York, NY 10027  |  New York  |  NY   |  40.8075395 |-73.9670574  | 60               | 0000      | 0000       |

Scenario: search for traveling plan suggestions w/o adding stops
  Given I am on the home page
  When I select "NY" from "State*" 
  And  I select "2" from "Number of Traveling Days*"
  And  I press "Search"
  Then I should be on the suggestion page
  Then I should see "Suggestion 1"
  Then I should see "Suggestion 2"

Scenario: clear all fields after click "Clear" btn
  Given I am on the home page
  When I select "NY" from "State*" 
  And  I select "2" from "Number of Traveling Days*"
  And  I follow "Clear"
  Then I should see "NY"
  And I should see "1"
  And I should be on the home page

Scenario: search for traveling plan suggestions with adding stops
  Given I am on the home page
  When I select "NY" from "State*" 
  And  I select "2" from "Number of Traveling Days*"
  And  I select "New York" from "Stop"
  And  I press "Search"
  Then I should be on the suggestion page
  Then I should see "Suggestion 1"
  Then I should see "Suggestion 2"
  Then I should see attractions in stop "New York" in all suggestions



