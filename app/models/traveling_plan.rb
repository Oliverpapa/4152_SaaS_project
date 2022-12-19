class TravelingPlan

  # newtype Plan = Object {
  #   id: Int,
  #   state: String,
  #   schedule_by_day: [OneDaySchedule],
  #   number_of_days: Int
  # }
  # newtype OneDaySchedule = Map<String, Attraction> # key means time ("8:00")

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

    return [generate_plan(attractions, state, cities, days, false),
            generate_plan(attractions, state, cities, days, true)]
  end

  def self.distance_to(attraction1, attraction2)
    # calculate the distance between two attractions using latitude and longitude
    coord1 = [attraction1.latitude, attraction1.longitude]
    coord2 = [attraction2.latitude, attraction2.longitude]

    # convert decimal degrees to radians
    coord1 = coord1.map { |x| x * Math::PI / 180 }
    coord2 = coord2.map { |x| x * Math::PI / 180 }

    # calculate the distance
    radius = 6371 # km
    dlat = coord2[0] - coord1[0]
    dlon = coord2[1] - coord1[1]
    a = Math.sin(dlat/2) * Math.sin(dlat/2) + Math.cos(coord1[0]) * Math.cos(coord2[0]) * Math.sin(dlon/2) * Math.sin(dlon/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    d = radius * c
    return d
  end

  def self.schedule_for_one_day(attractions:, more_attractions:true)
    # create a weighted graph with attractions as nodes, and distances as weights
    graph = Graph.new
    for attraction in attractions do
      graph.add_node(attraction)
    end
    for attraction in attractions do
      for other_attraction in attractions do
        if attraction != other_attraction
          node = graph.find_node(attraction)
          other_node = graph.find_node(other_attraction)
          node.add_edge(other_node, distance_to(attraction, other_attraction))
        end
      end
    end
    
    # use greedy algorithm to generate schedules
    # less gap time and more max attractions for more_attractions
    gap_time = more_attractions ? 1.hours : 2.hours
    max_attractions = more_attractions ? 5 : 2
    schedules, total_ratings = graph.greedy(gap_time, max_attractions)

    # select the schedule with the highest total rating
    max_index = total_ratings.each_with_index.max[1]
    schedule = schedules[max_index]

    return schedule
  end

  private
  def self.generate_plan(attractions, state, cities, days, more_attractions=true)
    plan = TravelingPlan.new(state: state, number_of_days: days)
    for day in 0..(days.to_i - 1)
      candidates = day >= cities.length ? attractions : Attraction.where(city: cities[day])
      schedule = schedule_for_one_day(attractions: candidates, more_attractions: more_attractions)
      plan.schedule_by_day = plan.schedule_by_day << schedule
      attractions = attractions.difference(schedule.values)
    end
    return plan
  end
end

# implementation of graph data structure
class Node

  attr_accessor :attraction, :edges, :distance, :previous
  
  def initialize
    @edges = []
  end
  
  def add_edge(node, weight)
    @edges << Edge.new(node, weight)
  end
end
  
class Edge

  attr_accessor :node, :weight
  
  def initialize(node, weight)
    @node = node
    @weight = weight
  end
end
  
class Graph

  attr_accessor :nodes
  
  def initialize
    @nodes = []
  end
  
  def add_node(attraction)
    node = Node.new
    node.attraction = attraction
    @nodes << node
  end

  def find_node(attraction)
    for node in @nodes do
      if node.attraction == attraction
        return node
      end
    end
  end

  def greedy(gap_time, max_attractions)
    # use greedy algorithm to generate all possible schedules, at most max_attractions attractions
    schedules = []
    total_ratings = []
    for node in @nodes do
      schedule = {}
      total_rating = 0
      num_of_attractions = 0
      clock = TimeOfDay.new(10)
      threshold = TimeOfDay.new(18)
      attraction = node.attraction
      clock = [clock, attraction.open_time.to_time_of_day].max
      # greedy algorithm to find the next nearest attraction to visit
      while clock + attraction.recommended_time.minutes < [threshold, attraction.close_time.to_time_of_day].min and num_of_attractions < max_attractions do
        schedule[clock] = attraction
        total_rating += attraction.rating
        clock += attraction.recommended_time.minutes + gap_time
        min_distance = Float::INFINITY
        next_attraction = nil
        for edge in node.edges do
          if edge.node.attraction.open_time.to_time_of_day <= clock and edge.node.attraction.close_time.to_time_of_day >= clock + edge.node.attraction.recommended_time.minutes and edge.weight < min_distance and not schedule.values.include? edge.node.attraction
            min_distance = edge.weight
            next_attraction = edge.node.attraction
          end
        end
        if next_attraction == nil
          break
        else
          attraction = next_attraction
        end
      end
      schedules << schedule
      total_ratings << total_rating
    end

    return schedules, total_ratings
  end
  
end


