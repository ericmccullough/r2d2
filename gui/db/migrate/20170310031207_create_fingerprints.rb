class CreateFingerprints < ActiveRecord::Migration
  def change
    create_table :fingerprints do |t|
      t.string :tcp_ports
      t.string :udp_ports
      t.string :shares

      t.timestamps null: false
    end
  end
end
