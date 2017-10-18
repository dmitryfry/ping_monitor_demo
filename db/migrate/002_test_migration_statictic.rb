class TestMigrationStatictic < ActiveRecord::Migration[5.0]
  def self.up
    create_table :statistics do |t|
      t.integer :host_id
      t.text :ping_ms
      t.text :pingfails
      t.text :average
      t.text :min
      t.text :max
      t.text :percent

      t.timestamps
    end
  end

  def self.down
    drop_table :statistic
  end
end
