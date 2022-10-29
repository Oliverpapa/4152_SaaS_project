require 'rails_helper'

describe TravelingPlan, type: :model do
  before do
    @attraction1 = Attraction.create()
  end

  describe '.generate_plan' do

    context 'generate plan w/o cities' do
      before do
        @plan = TravelingPlan.generate_plan(state: "NY", cities: [], days: 2)
      end

      it 'returns a valid traveling plan' do
      end
    end

    context 'generate plan with cities' do
      before do
        @plan = TravelingPlan.generate_plan(state: "NY", cities: ["New York"], days: 2)
      end

      it 'returns a valid traveling plan' do
      end

      it 'returns a plan that contains at least one attraction in the designated city' do
      end

    end
  end
end

describe Attraction, type: :model do
  before do
    @attraction1 = Attraction.create()
  end

end

describe Movie, type: :model do
  before do
    @movie1 = Movie.create(title: "1", director: "a")
    @movie2 = Movie.create(title: "2", director: "a")
    @movie3 = Movie.create(title: "3", director: "a")
    @movie4 = Movie.create(title: "4", director: "b")
    @movie5 = Movie.create(title: "5", director: "b")
  end

  describe '.search_similar' do
    context 'find movie(s) has the same director correctly' do
      it 'contain correct movies' do
        expect(Movie.search_similar(@movie1.id)).to include(@movie1, @movie2, @movie3)
        expect(Movie.search_similar(@movie4.id)).to include(@movie4, @movie5)
      end
      it 'do not contain incorrect movies' do
        expect(Movie.search_similar(@movie1.id)).to_not include(@movie4, @movie5)
        expect(Movie.search_similar(@movie4.id)).to_not include(@movie1, @movie2, @movie3)
      end
    end
  end
end