class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :edit, :update ]
  before_action :require_authentication, only: %i[edit update]


  def index
    # 1. Chronological order of Hijri months (see Book::HIJRI_MONTH_ORDER)
    @hijri_order = Book::HIJRI_MONTH_ORDER

    # 2. Fetch books and group them by the month we scraped
    # We use 'includes(:category)' to keep the app fast (preventing N+1 queries)
    @books_by_month = Book.includes(:category).where.not(reading_month: nil).group_by(&:reading_month)

    # Categories that appear in any listed book (dated + unsorted, for table filters)
    @filter_categories = Category.where(id: Book.distinct.select(:category_id)).order(:name)

    # 3. Optional: Books with no month found
    @unsorted_books = Book.where(reading_month: nil).includes(:category)
  end

  def show
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :description, :reading_month, :day_of_month,
      :category_id, :hijri_death_date, :pdf_url, :image_url, :url,
      :translated_pdf_url, :translated_editable_url)
  end
end
