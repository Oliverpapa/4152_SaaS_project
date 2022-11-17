
Given /the following attractions exist/ do |attraction_table|
  attraction_table.hashes.each do |attraction|
    Attraction.create attraction
  end
end

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  expect(page.body.index(e1) < page.body.index(e2))
end

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(', ').each do |rating|
    step %{I #{uncheck.nil? ? '' : 'un'}check "ratings_#{rating}"}
  end
end

Then /I should see attractions in stop "(.*)" in all suggestions/ do |city|
  # ensure that all suggestions div have at least one attraction in the designated city in suggestion view
  find("#suggestion1").should have_content(city)
  find("#suggestion2").should have_content(city)
end

Then /I press "(.*)" for "(.*)"/ do |button, suggestion|
  # ensure that the button is pressed for the designated suggestion
  if suggestion == "chill suggestion"
    find("#suggestion_0_#{button}").click
  else
    find("#suggestion_1_#{button}").click
  end
end

Then /I close "(.*)"/ do |attraction|
  sleep 3
  find("##{attraction.gsub(' ', '-')}-close").click
end

# https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js/blob/master/README.md
When /^I drag "(.*)" to "(.*)"$/ do |block, destination|
  # byebug
  # post = Post.find_by_title(post_title)
  block_id = block.gsub(' ', '-') + '-main-body'
  dest_id = destination.gsub(' ', '-') + '-main-body'

  find("##{block_id}").drag_to find("##{dest_id}")
end

Given /^I am at the customize page for the chill suggestion$/ do
  steps %(
    Given I am on the home page
    When I select "NY" from "travel_plan_state"
    And  I select "2" from "travel_plan_days"
    And  I press "Search"
    Then I press "Customize" for "chill suggestion"
    )
end
