class CreateJozuHolidays < ActiveRecord::Migration
  def change
    create_table :jozu_holidays do |t|
      t.string  :kind
      t.integer :user_id, :default => -1
      t.integer :non_working, :default => 1
      t.integer :month
      t.integer :day_or_week
      t.integer :year_from, :default => 0
      t.integer :year_to, :default => 9999
      t.string  :description, :default => ''
    end
  end
end
