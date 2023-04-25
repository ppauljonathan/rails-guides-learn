class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def abcd
    return render inline: '<h1>Special Render</h1>' if params[:id].to_i.even?

    render inline: '<h1>Regular Render</h1>'
  end
end
