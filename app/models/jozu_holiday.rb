# == Schema Information
#
# Table name: jozu_holidays
#
#     t.string  :kind
#     t.integer :month
#     t.integer :day_or_week
#     t.integer :year_from, :default => 0
#     t.integer :year_to, :default => 9999
#     t.string  :description, :default => ''
#
class JozuHoliday < ActiveRecord::Base
  unloadable

  validates_inclusion_of :kind,        presence: true, :in=> ['fixed', 'happy', 'corporate']
  validates              :month,       presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12}
  validates              :day_or_week, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31}
  validates              :year_from,   presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1945, less_than_or_equal_to: 9999}
  validates              :year_to,     presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1945, less_than_or_equal_to: 9999}

  after_save :clear_cache
  after_destroy :clear_cache

  @@holidays = nil
  @@fixed_holidays = nil
  @@happy_holidays = nil
  @@corporate_holidays = nil

  def self.insert_init_data
    init_holidays =[['fixed',   1,  1, 1949, 9999, '元日'],
                    ['fixed',   1, 15, 1949, 1999, '成人の日'],
                    ['happy',   1,  2, 2000, 9999, '成人の日'],
                    ['fixed',   2, 11, 1967, 9999, '建国記念の日'],
                    ['fixed',   4, 29, 1949, 1989, '天皇誕生日'],
                    ['fixed',   4, 29, 1990, 2006, 'みどりの日'],
                    ['fixed',   4, 29, 2007, 9999, '昭和の日'],
                    ['fixed',   5,  3, 1949, 9999, '憲法記念日'],
                    ['fixed',   5,  4, 1988, 2006, '国民の休日'],
                    ['fixed',   5,  4, 2007, 9999, 'みどりの日'],
                    ['fixed',   5,  5, 1949, 9999, 'こどもの日'],
                    ['happy',   7,  3, 2003, 9999, '海の日'],
                    ['fixed',   7, 20, 1996, 2002, '海の日'],
                    ['fixed',   8, 11, 2016, 9999, '山の日'],
                    ['fixed',   9, 15, 1966, 2002, '敬老の日'],
                    ['happy',   9,  3, 2003, 9999, '敬老の日'],
                    ['fixed',  10, 10, 1966, 1999, '体育の日'],
                    ['happy',  10,  2, 2000, 9999, '体育の日'],
                    ['fixed',  11,  3, 1948, 9999, '文化の日'],
                    ['fixed',  11, 23, 1948, 9999, '勤労感謝の日'],
                    ['fixed',  12, 23, 1989, 9999, '天皇誕生日'],
                    ['fixed',   4, 10, 1959, 1959, '皇太子明仁親王の結婚の儀'],
                    ['fixed',   2, 24, 1989, 1989, '昭和天皇の大喪の礼'],
                    ['fixed',  11, 12, 1990, 1990, '即位礼正殿の儀'],
                    ['fixed',   6,  9, 1993, 1993, '皇太子徳仁親王の結婚の儀']]

    init_holidays.each do |init_holiday|
      jozu_holiday             = JozuHoliday.new
      jozu_holiday.kind        = init_holiday[0]
      jozu_holiday.month       = init_holiday[1]
      jozu_holiday.day_or_week = init_holiday[2]
      jozu_holiday.year_from   = init_holiday[3]
      jozu_holiday.year_to     = init_holiday[4]
      jozu_holiday.description = init_holiday[5]
      jozu_holiday.save!
    end
  end

  def clear_cache
    @@holidays = nil
    @@fixed_holidays = nil
    @@happy_holidays = nil
    @@corporate_holidays = nil
  end

  def self.find_by_holiday
    unless @@holidays.present?
      @@holidays = JozuHoliday.where(['kind <> ?', 'corporate'])
      unless @@holidays.present?
        insert_init_data
        @@holidays = JozuHoliday.where(['kind <> ?', 'corporate'])
      end
    end

    return @@holidays
  end

  def self.find_by_fixed
    unless @@fixed_holidays.present?
      @@fixed_holidays = JozuHoliday.where(['kind = ?', 'fixed'])
    end

    return @@fixed_holidays
  end

  def self.find_by_happy
    unless @@happy_holidays.present?
      @@happy_holidays = JozuHoliday.where(['kind = ?', 'happy'])
    end

    return @@happy_holidays
  end

  def self.find_by_corporate
    unless @@corporate_holidays.present?
      @@corporate_holidays = JozuHoliday.where(['kind = ?', 'corporate'])
    end

    return @@corporate_holidays
  end

  def logger
    ::Rails.logger
  end

end

