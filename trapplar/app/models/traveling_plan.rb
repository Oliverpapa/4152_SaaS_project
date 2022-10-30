class TravelingPlan
  require 'tod'
  require 'tod/core_extensions'
  include Tod
  
  def self.generate_plan(state:, cities:, days:)
    # TODO: generate a plan based on state, cities, and days
    plan = []
    attractions = Attraction.where(state: state)
    for day in 0..(days-1)
      candidates = day >= cities.length ? attractions : Attraction.where(city: cities[day])
      schedule = generate_one_day_schedule(attractions: candidates)
      plan = plan << schedule
      attractions = attractions.difference(schedule.values)
    end
    return plan
  end

  def self.generate_one_day_schedule(attractions:)
    clock = TimeOfDay.new(10)
    gap_time = 2.hours
    threshold = TimeOfDay.new(18)
    schedule = {}
    for attraction in attractions do
      if clock + attraction.recommended_time.minutes < min(threshold, attraction.close_time.to_time_of_day)
        schedule[clock.to_s] = attraction
        clock += attraction.recommended_time.minutes + gap_time
      end
    end
    return schedule
  end

  attr_accessor :id, :state, :stops_details, :number_of_days

end
