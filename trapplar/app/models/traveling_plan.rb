class TravelingPlan

  def initialize(state:, number_of_days:)
    @id = 0
    @state = state
    @schedule_by_day = []
    @number_of_days = number_of_days
  end
  
  def self.generate_plans(state:, cities:, days:)
    plan = TravelingPlan.new(state: state, number_of_days: days)

    attractions = Attraction.where(state: state)
    p state, Attraction.all[0]
    cities.select! { |city| not city.empty?}

    for day in 0..(days.to_i - 1)
      candidates = day >= cities.length ? attractions : Attraction.where(city: cities[day])
      schedule = schedule_for_one_day(attractions: candidates)
      plan.schedule_by_day = plan.schedule_by_day << schedule
      attractions = attractions.difference(schedule.values)
    end

    return [plan, plan]
  end

  def self.schedule_for_one_day(attractions:)
    clock = TimeOfDay.new(10)
    gap_time = 2.hours
    threshold = TimeOfDay.new(18)
    schedule = {}
    for attraction in attractions do
      clock = [clock, attraction.open_time.to_time_of_day].max
      if clock + attraction.recommended_time.minutes < [threshold, attraction.close_time.to_time_of_day].min
        schedule[clock] = attraction
        clock += attraction.recommended_time.minutes + gap_time
      end
    end
    return schedule
  end

  attr_accessor :id, :state, :schedule_by_day, :number_of_days

end
