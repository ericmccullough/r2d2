class AddNameToFingerprint < ActiveRecord::Migration
  def change
    add_column :fingerprints, :name, :string
  end
end
