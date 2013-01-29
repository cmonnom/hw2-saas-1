class MoviesController < ApplicationController

helper_method :sort_movies

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    restore_session
    @all_ratings = Movie.ratings
    if !params[:ratings].nil?
      @filter_by = params[:ratings].keys
    else
      @filter_by = @all_ratings
    end
    if !params[:sorted_by].nil? and ["title", "release_date"].include?(params[:sorted_by])
      @movies = Movie.order(params[:sorted_by]).where(:rating => @filter_by)
      instance_variable_set("@#{params[:sorted_by]}_header", 'hilite')
    else params[:sorted_by].nil?
      @movies = Movie.where(:rating => @filter_by)
    end
    save_session
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def save_session
    session[:sorted_by] = params[:sorted_by]if !params[:sorted_by].nil?
    session[:ratings] = params[:ratings] if !params[:ratings].nil?
  end
  
  def restore_session
    @saved_params = Hash.new if @saved_params.nil?
    @saved_params[:sorted_by] = session[:sorted_by] if !session[:sorted_by].nil?
    @saved_params[:ratings] = session[:ratings] if !session[:ratings].nil?
    redirect_to movies_path(@saved_params) if !params_equal?
  end

  def params_equal?
    @equals = true
    @equals &= @saved_params[:sorted_by] == params[:sorted_by] if params[:sorted_by].nil?
    @equals &= @saved_params[:ratings] == params[:ratings] if params[:ratings].nil?
    @equals
  end
end
