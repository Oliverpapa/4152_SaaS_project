class Movie < ActiveRecord::Base
  def self.search_similar(movie_id)
    movie = Movie.find(movie_id)
    Movie.where(director: movie.director)
  end
end
