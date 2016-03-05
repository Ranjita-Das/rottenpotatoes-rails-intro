class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

 
    
  def index
      
    if params[:title_sort] == "selected"
      session[:movie_chosen] = "hilite"
      session[:date_chosen] = ""
    end
    
    if params[:date_sort] == "selected"
       session[:date_chosen] = "hilite"
      session[:movie_chosen] = ""
    end
    
    #sorting according to title
    if session[:movie_chosen] == "hilite"
      @movies = Movie.all.order(:title)
    #sorting according to release date
    elsif session[:date_chosen] == "hilite"
      @movies = Movie.all.order(:release_date)
    else
      @movies = Movie.all
    end
    
    if params[:ratings] != nil
      session[:chosen_ratings] = params[:ratings]
    end
    
    @all_ratings = Movie.select(:rating).uniq
    if session[:chosen_ratings] == nil
      session[:chosen_ratings] = Hash.new
      @all_ratings.each do |x|
        session[:chosen_ratings][x.rating] = 1
      end
    end
    
    @movies = @movies.where({rating: session[:chosen_ratings].keys})
    
    if session[:movie_chosen] == "hilite" and params[:title_sort].nil? and params[:date_sort].nil?
      params[:title_sort] = "selected"
    elsif session[:date_chosen] == "hilite" and params[:title_sort].nil? and params[:date_sort].nil? 
      params[:date_sort] = "selected"
    elsif params[:ratings].nil? and session[:chosen_ratings]
      params[:ratings] = session[:chosen_ratings]
      redirect_to movies_path(params)  #redirecting to list of movies
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
