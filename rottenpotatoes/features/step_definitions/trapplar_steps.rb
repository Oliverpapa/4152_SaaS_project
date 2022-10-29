
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

Then /I should see attractions in stop "(.*)"/ in all suggestions/ do |city|
  # Make sure that suggestion contains attractions in city
  TravelingPlan.all.each do |movie|
    step %{I should see "#{movie.title}"}
  end
end

Then /^the director of "(.+)" should be "(.+)"/ do |movie_name, director|
  movie = Movie.find_by_title(movie_name)
  expect(page).to have_content(/Director:\s#{director}/)
end