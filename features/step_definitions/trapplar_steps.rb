
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
  find("#suggestion1").should have_content(suggestion)
  find("#suggestion1").click_button(button)
end

# https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js/blob/master/README.md
When /^I drag "(.*)" (up|down) (\d+) positions?$/ do |post_title, direction, distance|
  post = Post.find_by_title(post_title)
  distance = distance.to_i * -1 if direction == 'up'
  page.execute_script %{
    $.getScript("http://your.bucket.s3.amazonaws.com/jquery.simulate.drag-sortable.js", function()
    {
      $("li#post_#{post.id}").simulateDragSortable({ move: #{distance.to_i}});
    });
  }
  sleep 1 # Hack to ensure ajax finishes running (tweak/remove as needed for your suite)
end
