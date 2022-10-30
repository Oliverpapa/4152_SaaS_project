require 'rails_helper'

describe TravelingPlansController, type: :controller do
  before do
    @params = {state: 'NY', cities: ['New York'], days: 2}
    @attraction1 = Attraction.create({:name => 'The Met', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -74.0950799, :recommended_time => 180, :open_time=> "10:00:00", :close_time=> "21:00:00"})
    @attraction2 = Attraction.create({:name => 'MoMA ', :rating => 4.6, :address => '11 W 53rd St, New York, NY 10019', :city => 'New York', :state => 'NY', :latitude => 40.7484714, :longitude => -73.9944193, :recommended_time => 180, :open_time=> "10:30:00", :close_time=> "17:30:00"})
    @attraction3 = Attraction.create({:name => 'Statue of Liberty', :rating => 4.7, :address => 'Statue of Liberty, New York, NY 10004', :city => 'New York', :state => 'NY', :latitude => 40.6917572, :longitude => -74.0429902, :recommended_time => 180, :open_time=> "08:30:00", :close_time=> "16:00:00"})
    @attraction4 = Attraction.create({:name => 'Columbia University', :rating => 4.7, :address => 'Columbia University, New York, NY 10027', :city => 'New York', :state => 'NY', :latitude => 40.8075395, :longitude => -73.9670574, :recommended_time => 60, :open_time=> "00:00:00", :close_time=> "00:00:00"})
    @attraction5 = Attraction.create({:name => 'The Metropolitan Museum of Art', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -73.9654327, :recommended_time => 120, :open_time=> "10:00:00", :close_time=> "17:00:00"})
    @attraction6 = Attraction.create({:name => 'Times Square', :rating => 4.7, :address => 'Manhattan, NY 10036', :city => 'New York', :state => 'NY', :latitude => 40.7576753, :longitude => -73.9866887, :recommended_time => 60, :open_time=> "00:00:00", :close_time=> "00:00:00"})
    @attraction7 = Attraction.create({:name => 'Disney California Adventure Park', :rating => 4.7, :address => '1313 Disneyland Dr, Anaheim, CA 92802', :city => 'Anaheim', :state => 'CA', :latitude => 33.8061164, :longitude => -117.9230477, :recommended_time => 240, :open_time=> "08:00:00", :close_time=> "18:00:00"})
    @attraction8 = Attraction.create({:name => 'Griffith Observatory', :rating => 4.7, :address => '2800 E Observatory Rd, Los Angeles, CA 90027', :city => 'Los Angeles', :state => 'CA', :latitude => 34.1184385, :longitude => -118.3025822, :recommended_time => 60, :open_time=> "10:00:00", :close_time=> "22:00:00"})
  end

  describe 'search ' do
    it 'should render the search page' do
      get :search
      expect(response).to render_template('index')
    end

    it 'should call Attractions.states and Attractions.cities_in_state_hash' do
      expect(TravelingPlansController).to receive(:search)
      get :search
      expect(response.status).to eq(200)
      expect(Attraction).to receive(:states)
      expect(assigns(@states)).to eq(['NY', 'CA'])
      expect(Attraction).to receive(:cities_in_state_hash)
      expect(assigns(@cities_in_state_hash)).to eq({'NY' => ['New York'], 'CA' => ['Anaheim', 'Los Angeles']})
    end
  end

  describe 'suggestion' do    
    it 'should render the suggestion page' do
      get :suggestion, @params 
      expect(response).to render_template('suggestion')
    end

    it 'should call the controller method that performs a suggestion' do
      expect(TravelingPlansController).to receive(:suggestion).with(@params)
      expect(TravelingPlan).to receive(:generate_plan).with(@params)
      get :suggestion, @params 
      expect(response).to render_template('suggestion')
    end
  end
end