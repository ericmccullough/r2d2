class CreatePrefs < ActiveRecord::Migration
  def change
    create_table :prefs do |t|
      t.string :mac_separator, limit: 1
      t.boolean :mac_uppercase

      t.timestamps null: false
    end
  end
end
