class TravelingPlansController < ApplicationController

  def search
    # our first page, where users can enter state, cities, number of traveling days.
    @states = Attraction.states
    @cities_in_state_hash = Attraction.cities_in_state_hash
    @default_cities = @cities_in_state_hash[@states[0]] 
    @num_of_traveling_days = (1..10).to_a
    render :index
  end

  def suggestion
    # second page, show our recommended plans

    # if state is not selected, we will redirect to the first page
    if params[:travel_plan][:state].empty?
      flash[:notice] = "You must select a state!"
      redirect_to search_path
    else
      @travel_plan = params[:travel_plan]
      @suggestions = TravelingPlan.generate_plans(state: @travel_plan[:state], cities: @travel_plan[:cities], days: @travel_plan[:days])
      render "suggestion"
    end
  end

  # def edit
  #   # detail/edit page, where users can customize
  # end

  # def show
  #   # redirect to google map?
  # end

end
