class TravelingPlan
  
  def self.generate_plan(state:, cities:, days:)
    # TODO: generate a plan based on state, cities, and days
    plan = []
    attractions = Attraction.where(state: state)
    
    if cities.length == 1
      cities = []
    else
      cities = cities.slice(-1,1)
    end

    for day in 0..(days.to_i - 1)
      candidates = day >= cities.length ? attractions : Attraction.where(city: cities[day])
      schedule = generate_one_day_schedule(attractions: candidates)
      plan = plan << schedule
      attractions = attractions.difference(schedule.values)
    end
    puts(plan)
    return [plan, plan]
  end

  def self.generate_one_day_schedule(attractions:)
    clock = TimeOfDay.new(10)
    gap_time = 2.hours
    threshold = TimeOfDay.new(18)
    schedule = {}
    attractions.each do |attraction|
      puts(attraction.name, attraction.close_time)
    end

    for attraction in attractions do
      if clock + attraction.recommended_time.minutes < [threshold, attraction.close_time.to_time_of_day].min
        schedule[clock.to_s] = attraction
        clock += attraction.recommended_time.minutes + gap_time
      end
    end
    return schedule
  end

  attr_accessor :id, :state, :stops_details, :number_of_days

end
