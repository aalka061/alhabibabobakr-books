class AddTranslatedPdfUrlToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :translated_pdf_url, :string
  end
end
