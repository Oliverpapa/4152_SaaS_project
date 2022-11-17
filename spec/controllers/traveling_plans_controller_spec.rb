require 'rails_helper'

describe TravelingPlansController, type: :controller do
  before :all do
    @params = {state: 'NY', cities: ['New York'], days: "2"}
    Attraction.delete_all
    @attraction1 = Attraction.create({:name => 'The Met', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -74.0950799, :recommended_time => 180, :open_time=> "10:00:00", :close_time=> "21:00:00"})
    @attraction2 = Attraction.create({:name => 'MoMA', :rating => 4.6, :address => '11 W 53rd St, New York, NY 10019', :city => 'New York', :state => 'NY', :latitude => 40.7484714, :longitude => -73.9944193, :recommended_time => 180, :open_time=> "10:30:00", :close_time=> "17:30:00"})
    @attraction3 = Attraction.create({:name => 'Statue of Liberty', :rating => 4.7, :address => 'Statue of Liberty, New York, NY 10004', :city => 'New York', :state => 'NY', :latitude => 40.6917572, :longitude => -74.0429902, :recommended_time => 180, :open_time=> "08:30:00", :close_time=> "16:00:00"})
    @attraction4 = Attraction.create({:name => 'Columbia University', :rating => 4.7, :address => 'Columbia University, New York, NY 10027', :city => 'New York', :state => 'NY', :latitude => 40.8075395, :longitude => -73.9670574, :recommended_time => 60, :open_time=> "00:00:00", :close_time=> "00:00:00"})
    @attraction5 = Attraction.create({:name => 'The Metropolitan Museum of Art', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -73.9654327, :recommended_time => 120, :open_time=> "10:00:00", :close_time=> "17:00:00"})
    @attraction6 = Attraction.create({:name => 'Times Square', :rating => 4.7, :address => 'Manhattan, NY 10036', :city => 'New York', :state => 'NY', :latitude => 40.7576753, :longitude => -73.9866887, :recommended_time => 60, :open_time=> "00:00:00", :close_time=> "00:00:00"})
    @attraction7 = Attraction.create({:name => 'Disney California Adventure Park', :rating => 4.7, :address => '1313 Disneyland Dr, Anaheim, CA 92802', :city => 'Anaheim', :state => 'CA', :latitude => 33.8061164, :longitude => -117.9230477, :recommended_time => 240, :open_time=> "08:00:00", :close_time=> "18:00:00"})
    @attraction8 = Attraction.create({:name => 'Griffith Observatory', :rating => 4.7, :address => '2800 E Observatory Rd, Los Angeles, CA 90027', :city => 'Los Angeles', :state => 'CA', :latitude => 34.1184385, :longitude => -118.3025822, :recommended_time => 60, :open_time=> "10:00:00", :close_time=> "22:00:00"})
  end

  describe 'search ' do
    it 'should call Attractions.states and Attractions.cities_in_state_hash' do
      expect_any_instance_of(TravelingPlansController).to receive(:search).and_call_original
      get :search
      expect(assigns(:states)).to eq(['NY', 'CA'])
      expect(assigns(:cities_in_state_hash)).to eq({'NY' => ['New York'], 'CA' => ['Anaheim', 'Los Angeles']})
      expect(response).to render_template('index')
    end

    it 'should stay in the same page if state is not selected' do
      get :suggestion, travel_plan: {state: '', cities: ['New York'], days: 2}
      expect(flash[:notice]).to eq('You must select a state!')
      expect(response).to redirect_to(search_path)
    end
  end

  describe 'suggestion' do    
    it 'should call the controller method that performs a suggestion' do
      expect_any_instance_of(TravelingPlansController).to receive(:suggestion).and_call_original
      expect(TravelingPlan).to receive(:generate_plans).with(@params)
      get :suggestion, travel_plan: @params
      expect(response).to render_template('suggestion')
    end

    it 'should return to the search page if no session data is found and no params are passed' do
      get :suggestion
      expect(response).to redirect_to(search_path)
    end

    it 'should restore the session data if no params are passed' do
      get :suggestion, travel_plan: @params
      get :suggestion
      expect assigns(:travel_plan["state"]) == 'NY'
      expect assigns(:travel_plan["cities"]) == ['New York']
      expect assigns(:travel_plan["days"]) == 2
    end
  end

  describe 'customize' do
    it 'should call the controller method that performs a customization with session data' do
      expect_any_instance_of(TravelingPlansController).to receive(:customize).and_call_original
      session[:travel_plan] = @params
      get :customize, {suggestion_type: 0}
      expect(response).to render_template('customize')
    end

    it 'should return to the suggestion page if session data is not available' do
      get :customize, {suggestion_type: 0}
      expect(response).to redirect_to(search_path)
    end
      
  end
end
