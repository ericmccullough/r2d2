class AddMacSeparatorsToPrefs < ActiveRecord::Migration
  def change
    add_column :prefs, :mac_separators, :string
  end
end
