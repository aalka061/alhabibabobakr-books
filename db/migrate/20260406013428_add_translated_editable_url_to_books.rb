class AddTranslatedEditableUrlToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :translated_editable_url, :string
  end
end
