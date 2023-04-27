class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def abcd
    return render inline: '<h1>Special Render</h1>' if params[:id].to_i.even?

    render inline: '<h1>Regular Render</h1>'
  end

  def search
    p 'LOG', params

    render :new
  end

  def new
    @book = Book.new
  end

  def edit
    @book = Book.find(params[:id])
  end

  def create
    p 'LOG', params
    redirect_to '/books/new'
  end

  def update
    p 'LOG', params
  end

  def destroy
    p 'LOG', params
  end

end
