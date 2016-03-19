class JozuGanttProjectSettings < ActiveRecord::Base

  ALL_PROJECT = -1
  ALL_PROJECT.freeze

  def self.find_or_create(project_id)
    jozu_gantt_settings = JozuGanttProjectSettings.where(['project_id = ?', project_id]).first()

    unless jozu_gantt_settings.present?
      if project_id != ALL_PROJECT
        jozu_gantt_settings = JozuGanttProjectSettings.where(['project_id = ?', ALL_PROJECT]).first()
      end
      jozu_gantt_settings = JozuGanttProjectSettings.new unless jozu_gantt_settings.present?

      jozu_gantt_settings.project_id    = project_id
      jozu_gantt_settings.show_assign   = 1
      jozu_gantt_settings.subject_width = 200
      jozu_gantt_settings.assign_width  = 100

      jozu_gantt_settings.save!
    end

    return jozu_gantt_settings
  end

  def logger
    ::Rails.logger
  end

end
