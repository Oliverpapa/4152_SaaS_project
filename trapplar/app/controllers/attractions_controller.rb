class AttractionsController < ApplicationController

    def show
      id = params[:id] # retrieve attraction ID from URI route
      @attraction = Attraction.find(id) # look up attraction by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @attractions = Attraction.all
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @attraction = Attraction.create!(attraction_params)
      flash[:notice] = "#{@attraction.name} was successfully created."
      #redirect_to movies_path
    end
  
    def edit
      @attraction = Attraction.find params[:id]
    end
  
    def update
      @attraction = Attraction.find params[:id]
      @attraction.update_attributes!(attraction_params)
      flash[:notice] = "#{@attraction.name} was successfully updated."
      #redirect_to movie_path(@movie)
    end
  
    def destroy
      @attraction = Attraction.find(params[:id])
      @attraction.destroy
      flash[:notice] = "Attraction '#{@attraction.name}' deleted."
      #redirect_to movies_path
    end
  
    
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def attraction_params
      params.require(:attraction).permit(:name, :address, :city, :state, :latitude, :longitude, :recommended_time, :rating, :open_time, :close_time)
    end
  end
  