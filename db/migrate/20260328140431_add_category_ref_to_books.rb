class AddCategoryRefToBooks < ActiveRecord::Migration[7.2]
  def change
    add_reference :books, :category, null: false, foreign_key: true
  end
end
