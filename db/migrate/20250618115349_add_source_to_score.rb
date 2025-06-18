class AddSourceToScore < ActiveRecord::Migration[8.0]
  def change
    add_column :scores, :source, :string
  end
end
