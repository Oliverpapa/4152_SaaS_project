class TravelingPlan
  def self.generate_plan(state:, cities:, days:)
    # TODO: generate a plan based on state, cities, and days
    # return a list of attractions
    # fake data for now
    [
      Attraction.new(name: "Central Park", address: "Central Park West", city: "New York", state: "NY", latitude: 40.7829, longitude: -73.9654, recommended_time: 2, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Empire State Building", address: "350 5th Ave", city: "New York", state: "NY", latitude: 40.7484, longitude: -73.9857, recommended_time: 1, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Times Square", address: "Broadway", city: "New York", state: "NY", latitude: 40.7589, longitude: -73.9851, recommended_time: 1, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Statue of Liberty", address: "Liberty Island", city: "New York", state: "NY", latitude: 40.6892, longitude: -74.0445, recommended_time: 1, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Brooklyn Bridge", address: "Brooklyn Bridge Park", city: "New York", state: "NY", latitude: 40.7061, longitude: -73.9969, recommended_time: 1, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Metropolitan Museum of Art", address: "1000 5th Ave", city: "New York", state: "NY", latitude: 40.7794, longitude: -73.9632, recommended_time: 2, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Grand Central Terminal", address: "89 E 42nd St", city: "New York", state: "NY", latitude: 40.7527, longitude: -73.9772, recommended_time: 1, rating: 4, open_time: 8, close_time: 18),
      Attraction.new(name: "Museum of Modern Art", address: "11 W 53rd St", city: "New York", state: "NY", latitude: 40.7614, longitude: -73.9776, recommended_time: 2, rating: 4, open_time: 8, close_time: 18)
    ]
  end

end
