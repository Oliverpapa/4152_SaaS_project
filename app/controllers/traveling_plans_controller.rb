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
    if params[:travel_plan] == nil
      if session[:travel_plan] == nil
        redirect_to search_path
      else
        @travel_plan = session[:travel_plan]
      end
    else
      if params[:travel_plan][:state].empty?
        flash[:notice] = "You must select a state!"
        redirect_to search_path
      else
        @travel_plan = params[:travel_plan]
        session[:travel_plan] = @travel_plan
      end
    end
    @suggestions = TravelingPlan.generate_plans(state: @travel_plan[:state], cities: @travel_plan[:cities], days: @travel_plan[:days])
    render "suggestion"
  end

  def customize
    if session[:travel_plan] == nil
      redirect_to search_path
    end
    @travel_plan = session[:travel_plan]
    @suggestions = TravelingPlan.generate_plans(state: @travel_plan[:state], cities: @travel_plan[:cities], days: @travel_plan[:days])
    
    if params[:suggestion_type] == nil
      redirect_to suggestion_path
    else
      @customize_plan = @suggestions[params[:suggestion_type]]
    end
    # third page, customize the selected traveling plan
    @state = @travel_plan[:state]
    @addable_attractions = Attraction.where(state: @state)
    @attraction_location_hash = Attraction.attraction_location_hash(state: @state)
    render "customize"
  end
      
  # def show
  #   # redirect to google map?
  # end

end
