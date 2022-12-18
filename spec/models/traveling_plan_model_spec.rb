require 'rails_helper'

describe TravelingPlan, type: :model do
  before :all do
    Attraction.delete_all
    @attraction1 = Attraction.create!({:name => 'The Met', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -74.0950799, :recommended_time => 180, :open_time=> "10:00:00", :close_time=> "21:00:00"})
    @attraction2 = Attraction.create!({:name => 'MoMA ', :rating => 4.6, :address => '11 W 53rd St, New York, NY 10019', :city => 'New York', :state => 'NY', :latitude => 40.7484714, :longitude => -73.9944193, :recommended_time => 180, :open_time=> "10:30:00", :close_time=> "17:30:00"})
    @attraction3 = Attraction.create!({:name => 'Statue of Liberty', :rating => 4.7, :address => 'Statue of Liberty, New York, NY 10004', :city => 'New York', :state => 'NY', :latitude => 40.6917572, :longitude => -74.0429902, :recommended_time => 180, :open_time=> "08:30:00", :close_time=> "16:00:00"})
    @attraction4 = Attraction.create!({:name => 'Columbia University', :rating => 4.7, :address => 'Columbia University, New York, NY 10027', :city => 'New York', :state => 'NY', :latitude => 40.8075395, :longitude => -73.9670574, :recommended_time => 60, :open_time=> "08:00:00", :close_time=> "20:00:00"})
    @attraction5 = Attraction.create!({:name => 'The Metropolitan Museum of Art', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -73.9654327, :recommended_time => 120, :open_time=> "10:00:00", :close_time=> "17:00:00"})
    @attraction6 = Attraction.create!({:name => 'Times Square', :rating => 4.7, :address => 'Manhattan, NY 10036', :city => 'New York', :state => 'NY', :latitude => 40.7576753, :longitude => -73.9866887, :recommended_time => 60, :open_time=> "10:00:00", :close_time=> "20:00:00"})
    @attraction7 = Attraction.create!({:name => 'Rockefeller Center', :rating => 4.7, :address => '45 Rockefeller Plaza, New York, NY 10111', :city => 'New York', :state => 'NY', :latitude => 40.7587402, :longitude => -73.9808623, :recommended_time => 120, :open_time=> "10:00:00", :close_time=> "20:00:00"})
    @attraction8 = Attraction.create!({:name => 'Kaaterskill Falls, Viewing Platform', :rating => 4.8, :address => 'Laurel House Rd, Palenville, NY 12463', :city => 'Palenville', :state => 'NY', :latitude => 42.6135313, :longitude => -74.3227508, :recommended_time => 180, :open_time=> "08:00:00", :close_time=> "18:00:00"})
  end

  shared_examples 'an one-day schedule' do
    it 'is not empty' do
      expect(schedule).to_not be_empty
    end
    it 'is not over 5 stops' do
      expect(schedule.length).to be <= 5
    end
    it 'contains schedule details as (Time, Attraction) pairs' do
      schedule.each do |time, stop|
        expect(time).to be_a(TimeOfDay)
        expect(stop).to be_an(Attraction)
      end
    end
    it 'visits stop within their opening hours' do
      schedule.each do |time, stop|
        expect(time).to be_between(stop.open_time.to_time_of_day, stop.close_time.to_time_of_day)
      end
    end
    it 'has at lease 30 mins of gap between attractions' do
      times = []
      schedule.each do |time, stop|
        times << time << time + stop.recommended_time.minutes + 30.minutes
      end
      expect(times).to eq times.sort
    end
  end

  shared_examples 'a plan' do
    it 'is a complete traveling plan' do
      expect(plan.id).to be_an(Integer)
      expect(plan.state).to be_a(String)
      expect(plan.schedule_by_day).to be_a(Array)
      plan.schedule_by_day.each do |one_day_schedule|
        expect(one_day_schedule).to be_a(Hash)
      end
    end

    it 'takes designated number of days' do
      expect(plan.schedule_by_day.length).to eq plan.number_of_days
    end

    it 'has no duplicated attractions' do
      attractions = plan.schedule_by_day.reduce({}, :merge).values
      expect(attractions).to eq attractions.uniq
    end

    context 'the schdule of the first day' do
      let(:schedule) { plan.schedule_by_day[0] }
      include_examples 'an one-day schedule'
    end
  end

  shared_examples 'a suggestion' do

    it 'contains exactly two plans' do
      expect(plans.length).to eq 2
    end

    context 'the chill plan' do
      let(:plan) { plans[0] }
      include_examples 'a plan'
    end

    context 'the hustle plan' do
      let(:plan) { plans[1] }
      include_examples 'a plan'
    end

    it 'the chill plan is shorter than the hustle plan' do
      chill_plan_length = plans[0].schedule_by_day.reduce({}, :merge).length
      hustle_plan_length = plans[1].schedule_by_day.reduce({}, :merge).length
      expect(chill_plan_length).to be <= hustle_plan_length
    end
  end

  describe '.generate_plans' do

    context 'w/o cities' do
      let(:plans) { TravelingPlan.generate_plans(state: "NY", cities: [], days: 2) }

      include_examples 'a suggestion'
    end

    context 'with cities' do
      let(:cities) { ["New York", "Palenville"] }
      let(:plans) { TravelingPlan.generate_plans(state: "NY", cities: cities, days: 2) }

      include_examples 'a suggestion'

      it 'each plan contains at least one attraction in each city' do
        plans.each do |plan|
          stops_in_plan = plan.schedule_by_day.reduce({}, :merge).values
          cities.each do |city|
            expect(stops_in_plan.any? { |stop| stop.city == city }).to be true
          end
        end
      end

    end
  end

  describe '.schedule_for_one_day' do
    let(:schedule) { TravelingPlan.schedule_for_one_day(attractions: Attraction.all) }
    include_examples('an one-day schedule')
  end
end
