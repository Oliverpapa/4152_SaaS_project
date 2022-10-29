require 'rails_helper'

describe TravelingPlansController, type: :controller do
  before do
    @movie1 = Movie.create(title: "1", director: "a")
    @movie2 = Movie.create(title: "2", director: "a")
    @movie3 = Movie.create(title: "3")
    @movie4 = Movie.create(title: "4", director: "b")
    @movie5 = Movie.create(title: "5", director: "b")
  end

  describe 'GET ' do
    before do
      get :show, id: @movie1.id
    end

    it 'should render #show' do
      expect(response).to render_template('show')
    end

    it 'should show correct movie' do
      expect(assigns(:movie)).to eql(@movie1)
    end

  end
  
  describe 'GET index' do
    it 'should render index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET new' do
    it 'should render new' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    before(:each) do
      @number_of_movie_before = Movie.count
      post :create, movie: {title: "new"}
    end

    it 'add new movie' do
      expect(Movie.find_by_title("new")).should_not be_nil
      expect(Movie.count).to eql(@number_of_movie_before+1)
    end

    it 'redirects to home page' do
      expect(response).to redirect_to(movies_path)
    end
  end

  describe 'GET edit' do
    before do
      get :edit, id: @movie1.id
    end

    it 'should render edit' do
      expect(response).to render_template('edit')
    end

    it 'should find the movie' do
      expect(assigns(:movie)).to eql(@movie1)
    end

  end

  describe 'PUT #update' do
    before(:each) do
      put :update, id: @movie1.id, movie: {title: "1_updated", director: "a"}
    end

    it 'updates an existing movie' do
      movie1_updated = Movie.find(@movie1.id)
      expect(movie1_updated.title).to eql('1_updated')
    end

    it 'redirects to show' do
      expect(response).to redirect_to(movie_path(@movie1))
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @number_of_movie_before = Movie.count
      delete :destroy, id: @movie1.id
    end

    it 'delete a movie' do
      expect(Movie.all).to_not include(@movie1)
      expect(Movie.count).to eql(@number_of_movie_before-1)
    end

    it 'redirects to home page' do
      expect(response).to redirect_to(movies_path)
    end
  end

  describe 'Find Movies With Same Director' do

    it 'if has director, return movies with the same director' do
      get :search_similar, { id: @movie1.id }
      expect(assigns(:similar_movies)).to include(@movie1, @movie2)
    end

    it 'if has director, do not return movies with different director' do
      get :search_similar, { id: @movie4.id }
      expect(assigns(:similar_movies)).to_not include(@movie1, @movie2, @movie3)
    end

    it "if does not have director, redirect to home page, " do
      get :search_similar, { id: @movie3.id }
      expect(response).to redirect_to(movies_path)
      expect(flash[:notice]).to eql("'3' has no director info")
    end
  end
end