class JozuGanttSettingsController < ApplicationController
  unloadable

  include Redmine::Utils::DateCalculation

  before_filter :find_project

  # for admin setting
  def index
    @jozu_holidays = JozuHoliday.find_by_holiday()
  end

  # for admin setting
  def edit
    jozu_gantt_setting_params.map do |id, jozu_gantt_setting_param|

      jozu_holiday = JozuHoliday.new() unless jozu_gantt_setting_param[:id].present?
      jozu_holiday = JozuHoliday.find(id) if jozu_gantt_setting_param[:id].present?

      # delete
      if jozu_gantt_setting_param[:_destroy] == "true"
        jozu_holiday.destroy
        next
      end

      # insert or update
      jozu_holiday.kind = jozu_gantt_setting_param[:kind]
      jozu_holiday.month = jozu_gantt_setting_param[:month]
      jozu_holiday.day_or_week = jozu_gantt_setting_param[:day_or_week]
      jozu_holiday.year_from = jozu_gantt_setting_param[:year_from]
      jozu_holiday.year_to = jozu_gantt_setting_param[:year_to]
      jozu_holiday.description = jozu_gantt_setting_param[:description]

      jozu_holiday.save
    end

    flash[:notice] = l(:noteice_successful_update)
    redirect_to :controller => 'jozu_gantt_settings',
                :action => 'index'
  end

  # for admin setting
  def jozu_gantt_setting_params
    params
      .permit(holidays: [:id, :kind, :month, :day_or_week, :year_from, :year_to, :description, :_destroy])[:holidays]
  end

  # project setting index
  def project_index
    @jozu_gantt_project_settings = JozuGanttProjectSettings.find_or_create(@project.id)
  end

  # project setting edit
  def project_edit
    if (params[:settings] != nil)
      # gantt settings
      @jozu_gantt_project_settings = JozuGanttProjectSettings.find_or_create(@project.id)
      @jozu_gantt_project_settings.show_assign   = params[:settings][:show_assign]
      @jozu_gantt_project_settings.subject_width = params[:settings][:subject_width]
      @jozu_gantt_project_settings.assign_width  = params[:settings][:assign_width]
      @jozu_gantt_project_settings.save

      flash[:notice] = l(:noteice_successful_update)
      redirect_to :controller => 'jozu_gantt_settings',
                  :action => 'project_index',
                  :project_id => @project
    end
  end

  def logger
    ::Rails.logger
  end

  # before filter
  def find_project
    if params[:project_id].present?
      @project = Project.find_by(identifier: params[:project_id])
    end
  end
end
