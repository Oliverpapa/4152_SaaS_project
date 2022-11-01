class Attraction < ActiveRecord::Base
  def self.states
    self.all.map(&:state).uniq
  end

  def self.cities_in_state_hash
    self.all.group_by(&:state).map { |state, attractions| [state, attractions.map(&:city).uniq] }.to_h
  end
end
