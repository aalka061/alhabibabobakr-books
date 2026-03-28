class AddReadingMonthToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :reading_month, :string
  end
end
