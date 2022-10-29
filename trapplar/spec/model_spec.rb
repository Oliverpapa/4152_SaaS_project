require 'rails_helper'

describe TravelingPlan, type: :model do
#  before do
#    @attraction1 = Attraction.create()
#  end

  shared_examples 'a plan' do
    it 'is a complete traveling plan' do
      expect(plan.id).to be_an(Integer)
      expect(plan.state).to be_a(String)
      expect(plan.stops_details).to be_a(Hash)
      expect(plan.stops_details).to_not be_empty
      expect(plan.number_of_days).to be_an(Integer)
    end
    it 'contains stops details as (DateTime, Attraction) pairs' do
      plan.stops_details.each do |date_time, stop|
        expect(date_time).to be_a(DateTime)
        expect(stop).to be_an(Attraction)
      end
    end
    it 'visits stop within their opening hours' do
      plan.stops_details.each do |date_time, stop|
        expect(date_time.to_time).to be_between(stop.open_time, stop.close_time)
      end
    end
    it 'takes less than the given number of days' do
      expect(plan.stops_details.keys.minmax { |min_date_time, max_date_time| max_date_time - min_date_time }).to be <= plan.num_of_days.days
    end
  end

  describe '.generate_plan' do

    context 'generate plan w/o cities' do

      let(:plan) { TravelingPlan.generate_plan(state: "NY", cities: [], days: 2) }

      it_behaves_like "a plan"
      
    end

    context 'generate plan with cities' do

      let(:cities) {["New York"]}
      let(:plan) { TravelingPlan.generate_plan(state: "NY", cities: cities, days: 2) }

      it_behaves_like "a plan"

      it 'the plan contains at least one attraction in each designated city' do
        cities.each do |city|
          expect(plan.stops_details.values.any? { |stop| stop.city == city }).to be true
        end
      end

    end
  end
end

describe Attraction, type: :model do
#  before do
#    @attraction1 = Attraction.create()
#  end

end
