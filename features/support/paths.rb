# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file is used by web_steps.rb, which you should also delete
#
# You have been warned
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/ then '/index'

    when /^the suggestion page$/ then '/suggestion'

    when /^the customize\s?page$/ then '/customize/0'

    # the customize page of the suggestion
    when /^the customize page for "(.+)"$/ 
      suggestion_type = $1
      if suggestion_type == "Hustle"
        customize_path({:suggestion_type => 1})
      else
        customize_path({:suggestion_type => 0})
      end

    # when /^the details page for "(.+)"$/
    #   movie = Movie.find_by_title($1)
    #   movie_path(movie)
    
    # when /Similar Movies page for "(.+)"$/
    #   movie_id = Movie.find_by_title($1).id
    #   similar_movies_path(movie_id)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
