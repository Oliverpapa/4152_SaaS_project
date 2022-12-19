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
    # add edges to the graph
    for attraction in attractions do
      for other_attraction in attractions do
        if attraction != other_attraction
          # find node of attraction
          node = graph.find_node(attraction)
          # find node of other_attraction
          other_node = graph.find_node(other_attraction)
          # add edge
          node.add_edge_1(other_node, distance_to(attraction, other_attraction))
        end
      end
    end
    
    # rank attractions by their ratings from high to low
    attractions = attractions.sort_by { |attraction| attraction.rating }.reverse

    # find the shortest path
    node_0 = graph.find_node(attractions[0])
    node_1 = graph.find_node(attractions[-1])
    shortest_path = graph.shortest_path(node_0, node_1)

    # create a schedule
    schedule = {}
    clock = TimeOfDay.new(10)
    # less gap time for more attractions
    #gap_time = more_attractions ? 0 : 2.hours
    #gap_time = more_attractions ? hour : 2.hours
    gap_time = 2.hours
    threshold = TimeOfDay.new(18)
    for node in shortest_path do
      attraction = node.attraction
      clock = [clock, attraction.open_time.to_time_of_day].max
      if clock + attraction.recommended_time.minutes < [threshold, attraction.close_time.to_time_of_day].min
        schedule[clock] = attraction
        clock += attraction.recommended_time.minutes + gap_time
      end
    end

    # print the schedule
    # for time in schedule.keys.sort do
    #   puts time.to_s + " " + schedule[time].name
    # end
    # puts "-----------------"
    
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
  
  def add_edge_1(node, weight)
    @edges << Edge.new(node, weight)
  end
  
  def to_s
    return "Node: " + self.object_id.to_s
  end
end
  
class Edge

  attr_accessor :node, :weight
  
  def initialize(node, weight)
    @node = node
    @weight = weight
  end
  
  def to_s
    return "Edge: " + self.node.object_id.to_s + " " + self.weight.to_s
  end
end
  
class PriorityQueue

  def initialize
    @nodes = []
  end
  
  def add(node)
    @nodes << node
  end
  
  def empty?
    return @nodes.empty?
  end
  
  def extract_min
    min = @nodes[0]
    for node in @nodes do
      if node.distance < min.distance
        min = node
      end
    end
    @nodes.delete(min)
    return min
  end
  
  def update(node)
    # do nothing
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

  def add_edge(node1, node2, weight)
    node1.add_edge_1(node2, weight)
  end
  
  def shortest_path(node1, node2)  
    # initialize
    for node in @nodes do
      node.distance = Float::INFINITY
      node.previous = nil
    end
    node1.distance = 0
  
    # create a priority queue
    queue = PriorityQueue.new
    for node in @nodes do
      queue.add(node)
    end

    # find the shortest path
    while not queue.empty?
      node = queue.extract_min
      for edge in node.edges do
        if edge.node.distance > node.distance + edge.weight
          edge.node.distance = node.distance + edge.weight
          edge.node.previous = node
          queue.update(edge.node)
        end
      end
    end

    # create the shortest path
    path = []
    node = node2
    while node != nil
      path << node
      node = node.previous
    end
    return path.reverse
  end

end


