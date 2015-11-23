class MoviesController < ApplicationController

  attr_accessor :sort_by, :all_ratings
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  #REFACTOR!!!
  def index
    redirect_needed = params[:ratings].nil? && params[:sort_by].nil?
    @all_ratings = Movie.get_ratings
    if params[:ratings].nil?
      @checked_ratings = session[:checked_ratings].nil? ? @all_ratings : session[:checked_ratings]
      params[:ratings] = @checked_ratings
    else
      @checked_ratings = params[:ratings].class == Array ? params[:ratings] : params[:ratings].keys
    end
    @movies = Movie.all.where(rating: @checked_ratings)
    params[:sort_by] = params[:sort_by].nil? ? session[:sort_by] : params[:sort_by]
    @sort_by = params[:sort_by]
    if @sort_by == 'title'
      @movies = @movies.order(:title)
    elsif @sort_by == 'release'
      @movies = @movies.order(:release_date)
    end
    session[:checked_ratings] = @checked_ratings
    session[:sort_by] = @sort_by
    if redirect_needed
      flash.keep
      redirect_to movies_path(:sort_by => @sort_by, :ratings => @checked_ratings)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
