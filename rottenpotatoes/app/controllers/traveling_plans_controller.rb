class TravelingPlansController < ApplicationController

  def search
    # our first page, where users can enter state, cities, etc.
    render :index
  end

  def suggestion
    # second page, show our recommended plans
    @suggestions = TravelingPlan.generate_plan(state: params[:state], cities: params[:cities], days: params[:days])
    render "suggestion"
  end

  def edit
    # detail/edit page, where users can customize
  end

  def show
    # redirect to google map?
  end

end