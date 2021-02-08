class MoviesController < ApplicationController
#byebug
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
#     @movies = Movie.all
    
    # filtering
    @all_ratings = Movie.all_ratings
    
    # check what session ratings selection is, and if nil, assign params and v.v.check
    if params[:ratings]==nil 
      if session[:ratings] != nil
        params[:ratings] = session[:ratings]
      end
    else
      session[:ratings] = params[:ratings]
    end
    
    ########
    # test
    
    if params[:ratings] == nil && session[:ratings] == nil
      redirect_to movies_path(:ratings => Hash[@all_ratings.collect { |v| [v, '1'] }])
    end
    if params[:ratings] != nil && session[:ratings] == nil
      session[:ratings] = params[:ratings]
    end
    if session[:ratings] != nil && params[:ratings] == nil
      params[:ratings] = session[:ratings]
    end
    
    
    ########
    
    if params[:ratings]==nil
      @ratings_to_show = @all_ratings
      @movies = Movie.all
      #@selected_ratings = @all_ratings
    else
      @ratings_to_show = params[:ratings].keys
      @movies = Movie.with_ratings(@ratings_to_show)
      #@selected_ratings = @ratings_to_show
    end
    
    # check what session sort selection is, and if nil, assign params and v.v.check
    if params[:sort]==nil 
      if session[:sort] != nil
        params[:sort] == session[:sort]
      end
    else
      session[:sort] = params[:sort]
    end
    
    # sorting
    if params[:sort] != nil
      @selected_sort = params[:sort]
      @movies = @movies.order(params[:sort])

      if params[:sort] == "title"
        @title_highlight = "hilite"
      end
      if params[:sort] == "release_date"
        @date_highlight = "hilite"
      end
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
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
