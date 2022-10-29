class TravelingPlansController < ApplicationController

  def search
    # our first page, where users can enter state, cities, number of traveling days.

    @states = Attraction.all.map(&:state).uniq
    @cities_in_state_hash = Attraction.all.group_by(&:state).map { |state, attractions| [state, attractions.map(&:city).uniq] }.to_h
    @num_of_traveling_days = (1..10).to_a
    render :index
  end

  def suggestion
    # second page, show our recommended plans
    @suggestions = TravelingPlan.generate_plan(state: params[:state], cities: params[:cities], days: params[:days])
    render "suggestion"
  end

  # def edit
  #   # detail/edit page, where users can customize
  # end

  # def show
  #   # redirect to google map?
  # end

end