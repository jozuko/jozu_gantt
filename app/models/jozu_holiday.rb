# encoding: utf-8
#
# Jozu Gantt Plugin - JozuHoliday
#
# The MIT License (MIT)
#
# Copyright (c) [2016] [jozuko]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# == Schema Information
#
# Table name: jozu_holidays
#
#     t.string  :kind
#     t.integer :user_id, :default => -1
#     t.integer :non_working, :default => 1
#     t.integer :month
#     t.integer :day_or_week
#     t.integer :year_from, :default => 0
#     t.integer :year_to, :default => 9999
#     t.string  :description, :default => ''
#
class JozuHoliday < ActiveRecord::Base
  unloadable

  # define const
  KIND_FIXED = 'fixed'
  KIND_FIXED.freeze

  KIND_HAPPY = 'happy'
  KIND_HAPPY.freeze

  KIND_CORPORATE = 'corporate'
  KIND_CORPORATE.freeze

  KIND_USER = 'user'
  KIND_USER.freeze

  USER_ALL = -1
  USER_ALL.freeze

  NON_WORKING_TRUE = 1
  NON_WORKING_TRUE.freeze

  NON_WORKING_FALSE = 0
  NON_WORKING_FALSE.freeze

  # define validate
  validates_inclusion_of :kind,        presence: true, :in=> [KIND_FIXED, KIND_HAPPY, KIND_CORPORATE, KIND_USER]
  validates              :non_working, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
  validates              :month,       presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12}
  validates              :day_or_week, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31}
  validates              :year_from,   presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1945, less_than_or_equal_to: 9999}
  validates              :year_to,     presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1945, less_than_or_equal_to: 9999}

  # define hook
  after_save :clear_cache
  after_destroy :clear_cache

  # define class valiable
  @@holidays = nil
  @@fixed_holidays = nil
  @@happy_holidays = nil
  @@corporate_holidays = nil
  @@corporate_workingdays = nil

  # CLASS insert_init_data
  def self.insert_init_data
    init_holidays =[[KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   1,  1, 1949, 9999, '元日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   1, 15, 1949, 1999, '成人の日'],
                    [KIND_HAPPY, USER_ALL, NON_WORKING_TRUE,   1,  2, 2000, 9999, '成人の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   2, 11, 1967, 9999, '建国記念の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   4, 29, 1949, 1989, '天皇誕生日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   4, 29, 1990, 2006, 'みどりの日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   4, 29, 2007, 9999, '昭和の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   5,  3, 1949, 9999, '憲法記念日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   5,  4, 1988, 2006, '国民の休日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   5,  4, 2007, 9999, 'みどりの日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   5,  5, 1949, 9999, 'こどもの日'],
                    [KIND_HAPPY, USER_ALL, NON_WORKING_TRUE,   7,  3, 2003, 9999, '海の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   7, 20, 1996, 2002, '海の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   8, 11, 2016, 9999, '山の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   9, 15, 1966, 2002, '敬老の日'],
                    [KIND_HAPPY, USER_ALL, NON_WORKING_TRUE,   9,  3, 2003, 9999, '敬老の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,  10, 10, 1966, 1999, '体育の日'],
                    [KIND_HAPPY, USER_ALL, NON_WORKING_TRUE,  10,  2, 2000, 9999, '体育の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,  11,  3, 1948, 9999, '文化の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,  11, 23, 1948, 9999, '勤労感謝の日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,  12, 23, 1989, 9999, '天皇誕生日'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   4, 10, 1959, 1959, '皇太子明仁親王の結婚の儀'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   2, 24, 1989, 1989, '昭和天皇の大喪の礼'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,  11, 12, 1990, 1990, '即位礼正殿の儀'],
                    [KIND_FIXED, USER_ALL, NON_WORKING_TRUE,   6,  9, 1993, 1993, '皇太子徳仁親王の結婚の儀']]

    init_holidays.each do |init_holiday|
      jozu_holiday             = JozuHoliday.new
      jozu_holiday.kind        = init_holiday[0]
      jozu_holiday.user_id     = init_holiday[1]
      jozu_holiday.non_working = init_holiday[2]
      jozu_holiday.month       = init_holiday[3]
      jozu_holiday.day_or_week = init_holiday[4]
      jozu_holiday.year_from   = init_holiday[5]
      jozu_holiday.year_to     = init_holiday[6]
      jozu_holiday.description = init_holiday[7]
      jozu_holiday.save!
    end
  end

  # INSTANCE clear_cache
  def clear_cache
    @@holidays = nil
    @@fixed_holidays = nil
    @@happy_holidays = nil
    @@corporate_holidays = nil
    @@corporate_workingdays = nil
  end

  # CLASS find_by_holiday
  def self.find_by_holiday
    unless @@holidays.present?
      @@holidays = JozuHoliday.where(['kind = ? or kind = ?', KIND_FIXED, KIND_HAPPY])
      unless @@holidays.present?
        insert_init_data
        @@holidays = JozuHoliday.where(['kind = ? or kind = ?', KIND_FIXED, KIND_HAPPY])
      end
    end

    return @@holidays
  end

  # CLASS find_by_fixed
  def self.find_by_fixed
    unless @@fixed_holidays.present?
      @@fixed_holidays = JozuHoliday.where(['kind = ?', KIND_FIXED])
    end

    return @@fixed_holidays
  end

  # CLASS find_by_happy
  def self.find_by_happy
    unless @@happy_holidays.present?
      @@happy_holidays = JozuHoliday.where(['kind = ?', KIND_HAPPY])
    end

    return @@happy_holidays
  end

  # CLASS find_by_corporate
  def self.find_by_corporate_holidays
    unless @@corporate_holidays.present?
      @@corporate_holidays = JozuHoliday.where(['kind = ? and non_working = ?', KIND_CORPORATE, NON_WORKING_TRUE])
    end

    return @@corporate_holidays
  end

  # CLASS find_by_corporate_workingdays
  def self.find_by_corporate_workingdays
    unless @@corporate_workingdays.present?
      @@corporate_workingdays = JozuHoliday.where(['kind = ? and non_working = ?', KIND_CORPORATE, NON_WORKING_FALSE])
    end

    return @@corporate_workingdays
  end

  def logger
    ::Rails.logger
  end

end

