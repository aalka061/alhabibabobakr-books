class AddCalendarFieldsToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :pdf_url, :string
  end
end
