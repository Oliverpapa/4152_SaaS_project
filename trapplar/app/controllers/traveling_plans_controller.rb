class TravelingPlansController < ApplicationController

  def search
    # our first page, where users can enter state, cities, number of traveling days.
    @states = Attraction.states
    @cities_in_state_hash = Attraction.cities_in_state_hash
    @num_of_traveling_days = (1..10).to_a
    render :index
  end

  def suggestion
    # second page, show our recommended plans
    travel_plan = params[:travel_plan]
    @suggestions = TravelingPlan.generate_plans(state: travel_plan[:state], cities: travel_plan[:stop], days: travel_plan[:traveling_days])
    render "suggestion"
  end

  # def edit
  #   # detail/edit page, where users can customize
  # end

  # def show
  #   # redirect to google map?
  # end

end
