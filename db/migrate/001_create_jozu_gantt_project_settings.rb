class CreateJozuGanttProjectSettings < ActiveRecord::Migration
  def change
    create_table :jozu_gantt_project_settings do |t|
      t.integer :project_id
      t.integer :show_assign, :default => 1
      t.integer :subject_width, :default => 200
      t.integer :assign_width, :default => 100
    end
  end
end
