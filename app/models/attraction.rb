class Attraction < ActiveRecord::Base
  def self.states
    self.all.map(&:state).uniq
  end

  def self.cities_in_state_hash
    self.all.group_by(&:state).map { |state, attractions| [state, attractions.map(&:city).uniq] }.to_h
  end

  def self.attraction_location_hash(state:)
    self.where(state: state).map { |attraction| [attraction.name, {"lat" => attraction.latitude, "lng" => attraction.longitude}] }.to_h
  end
end
