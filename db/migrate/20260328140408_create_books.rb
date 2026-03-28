class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :title
      t.text :description
      t.string :url
      t.string :published_at
      t.string :hijri_death_date

      t.timestamps
    end
  end
end
