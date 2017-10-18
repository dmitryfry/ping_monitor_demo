class TestMigration < ActiveRecord::Migration[5.0]
  def self.up
    create_table :hosts do |t|
      t.text :name, :null => false
    end
  end

  def self.down
    drop_table :hosts
  end
end
