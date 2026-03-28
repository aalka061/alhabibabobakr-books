class AddDayToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :day_of_month, :string
  end
end
