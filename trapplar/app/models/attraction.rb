class Attraction < ActiveRecord::Base
  def states
    all.map(&:state).uniq
  end

  def cities_in_state_hash
    all.group_by(&:state).map { |state, attractions| [state, attractions.map(&:city).uniq] }.to_h
  end
end
