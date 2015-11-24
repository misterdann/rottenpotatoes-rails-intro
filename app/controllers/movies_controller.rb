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

  def index
    redirect_needed = params[:ratings].nil? && params[:sort_by].nil?
    @all_ratings = Movie.get_ratings
    @checked_ratings = getCheckedRatings(@all_ratings)
    @movies = Movie.all.where(rating: @checked_ratings)
    
    @sort_by = params[:sort_by].nil? ? session[:sort_by] : params[:sort_by]
    @movies = getSortedMovies(@sort_by, @movies)
    
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
  
  private
  
  def getCheckedRatings(all_ratings)
    if params[:ratings].nil?
      return session[:checked_ratings].nil? ? all_ratings : session[:checked_ratings]
    else
      return params[:ratings].class == Array ? params[:ratings] : params[:ratings].keys
    end
  end
  
  def getSortedMovies(sort_by, movies)
    if sort_by == 'title'
      return @movies.order(:title)
    elsif sort_by == 'release'
      return @movies.order(:release_date)
    end
    movies
  end

end
