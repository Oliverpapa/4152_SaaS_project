class TravelingPlan

  attr_accessor :id, :state, :schedule_by_day, :number_of_days

  def initialize(state:, number_of_days:)
    @id = 0
    @state = state
    @schedule_by_day = []
    @number_of_days = number_of_days
  end
  
  def self.generate_plans(state:, cities:, days:)

    cities.select! { |city| not city.empty?}

    attractions = Attraction.where(state: state)

    return [generate_plan(attractions, state, cities, days),
            generate_plan(attractions.reverse, state, cities, days)]
  end

  def self.schedule_for_one_day(attractions:)
    clock = TimeOfDay.new(10)
    gap_time = 2.hours
    threshold = TimeOfDay.new(18)
    schedule = {}
    # rank attractions by their ratings from high to low
    attractions = attractions.sort_by { |attraction| attraction.rating }.reverse
    for attraction in attractions do
      clock = [clock, attraction.open_time.to_time_of_day].max
      if clock + attraction.recommended_time.minutes < [threshold, attraction.close_time.to_time_of_day].min
        schedule[clock] = attraction
        clock += attraction.recommended_time.minutes + gap_time
      end
    end
    return schedule
  end


  def self.generate_chill_plan(attractions:, state:, cities:, days:)
    # generate a plan that is not too busy
    plan = TravelingPlan.new(state: state, number_of_days: days)
    for day in 1..days do
      schedule = schedule_for_one_day(attractions: attractions)
      plan.schedule_by_day[day] = schedule
      attractions = attractions - schedule.values
    end
    return plan
  end

  def self.generate_hustle_plan(attractions:, state:, cities:, days:)
    # generate a plan that is very busy
    plan = TravelingPlan.new(state: state, number_of_days: days)
    for day in 1..days do
      schedule = schedule_for_one_day(attractions: attractions)
      plan.schedule_by_day[day] = schedule
      attractions = attractions - schedule.values
    end
    return plan
  end



def self.add_attraction_to_schedule(schedule, attraction, start_time)
    schedule[start_time] = attraction
    return schedule
  end

def self.remove_attraction_from_schedule(schedule, attraction)
  schedule.delete_if { |time, a| a == attraction }
  return schedule
end

def self.edit_attraction_in_schedule(schedule, attraction, start_time)
  schedule = remove_attraction_from_schedule(schedule, attraction)
  schedule = add_attraction_to_schedule(schedule, attraction, start_time)
  return schedule
end

def self.edit_attraction_recommended_time(schedule, attraction, recommended_time)
  schedule = remove_attraction_from_schedule(schedule, attraction)
  attraction.recommended_time = recommended_time
  schedule = add_attraction_to_schedule(schedule, attraction, start_time)
  return schedule
end


  private
  def self.generate_plan(attractions, state, cities, days)
    plan = TravelingPlan.new(state: state, number_of_days: days)
    for day in 0..(days.to_i - 1)
      candidates = day >= cities.length ? attractions : Attraction.where(city: cities[day])
      schedule = schedule_for_one_day(attractions: candidates)
      plan.schedule_by_day = plan.schedule_by_day << schedule
      attractions = attractions.difference(schedule.values)
    end
    return plan
  end

end
