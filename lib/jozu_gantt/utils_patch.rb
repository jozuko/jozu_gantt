# Jozu Gantt Plugin - lib/redmine/utils.rbの拡張
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

module JozuGantt::UtilsPatch
  def self.included(base) # :nodoc:
    base.class_eval do

      # working_days -> jozu_holi_working_days
      def working_days_with_jozu_holi_working_days(from, to)
        logger.info from.to_s + " - " + to.to_s

        holi_working_days(from, to)
      end

      # add_working_days -> jozu_holi_add_working_days
      def add_working_days_with_jozu_holi_add_working_days(date, working_days)
        holi_add_working_days(date, working_days)
      end

      # next_working_date -> jozu_holi_next_working_date
      def next_working_date_with_jozu_holi_next_working_date(date)
        holi_next_working_date(date)
      end

      # non_working_week_days -> jozu_holi_non_working_week_days
      def non_working_week_days_with_jozu_holi_non_working_week_days
        @non_working_week_days = begin
          days = Setting.find_non_working_week_days
          if days.is_a?(Array) && days.size < 7
            days.map(&:to_i)
          else
            []
          end
        end
      end

      # alias_method_chain
      alias_method_chain :working_days,          :jozu_holi_working_days
      alias_method_chain :add_working_days,      :jozu_holi_add_working_days
      alias_method_chain :next_working_date,     :jozu_holi_next_working_date
      alias_method_chain :non_working_week_days, :jozu_holi_non_working_week_days

      # holi_working_days
      def holi_working_days(from, to)
        date = holi_next_working_date(from)
        result = 0
        while date <= to
          result += 1
          date = holi_add_working_days(date, 2)
        end

        result
      end

      # holi_add_working_days
      def holi_add_working_days(date, working_days)
        if working_days > 0
          temp_date = holi_next_working_date(date)
          days_left = working_days - 1
          while days_left > 0 do
            temp_date = holi_next_working_date(temp_date + 1)
            days_left -= 1
          end
          temp_date
        elsif working_days < 0
          temp_date = holi_next_working_date(date)
          days_left = working_days
          while days_left < 0 do
            temp_date = holi_before_working_date(temp_date - 1)
            days_left += 1
          end
          temp_date
        else
          date
        end
      end

      # holi_next_working_date
      def holi_next_working_date(date)
        cwday = date.cwday
        days = 0
        reminder = -1

        while days != reminder do
          reminder = days

          while non_working_week_days.include?(((cwday + days - 1) % 7) + 1)
            days += 1
            next
          end

          while checkFixedHoliday((date + days))
            days += 1
            next
          end

          while checkHappyHoliday((date + days))
            days += 1
            next
          end

          while checkCorporateHoliday((date + days))
            days += 1
            next
          end
        end

        date + days
      end

      # holi_before_working_date
      def holi_before_working_date(date)
        cwday = date.cwday
        days = 0
        reminder = -1

        while days != reminder do
          reminder = days

          while non_working_week_days.include?(((cwday + days - 1) % 7) + 1)
            days -= 1
            next
          end

          while checkFixedHoliday((date + days))
            days -= 1
            next
          end

          while checkHappyHoliday((date + days))
            days -= 1
            next
          end

          while checkCorporateHoliday((date + days))
            days -= 1
            next
          end
        end

        date + days
      end

      # 固定休日をチェック
      def checkFixedHoliday(date)
        @fixed_holidays = JozuHoliday.find_by_fixed()
        unless @fixed_holidays.present?
          return false
        end

        @fixed_holidays.each do |fixed_holiday|

          # まずは年ではじく
          if date.year < fixed_holiday.year_from || date.year > fixed_holiday.year_to
            next
          end

          # 次に月ではじく
          if date.month != fixed_holiday.month
            next
          end

          # date.yearの祝日を作成 日曜日なら振替休日
          holiday = Date.new(date.year, fixed_holiday.month, fixed_holiday.day_or_week)
          if holiday.cwday == 7
            holiday += 1
          end

          # 一致を返却
          if date == holiday
            return true
          end
        end

        return false
      end

      # ハッピーマンデーをチェック
      def checkHappyHoliday(date)
        @happy_holidays = JozuHoliday.find_by_happy()
        unless @happy_holidays.present?
          return false
        end

        @happy_holidays.each do |happy_holiday|
          # まずは年ではじく
          if date.year < happy_holiday.year_from || date.year > happy_holiday.year_to
            next
          end

          # 次に月ではじく
          if date.month != happy_holiday.month
            next
          end

          # 第*月曜日の日付を求める
          first_day = Date.new(date.year, happy_holiday.month, 1)
          holiday = first_day + (7 * happy_holiday.day_or_week)
          holiday -= (first_day.cwday - 1)

          # 一致を返却
          if date == holiday
            return true
          end
        end

        return false
      end

      # 会社休日をチェック
      def checkCorporateHoliday(date)
        @corporate_holidays = JozuHoliday.find_by_corporate()
        unless @corporate_holidays.present?
          return false
        end

        @corporate_holidays.each do |corporate_holiday|
          # まずは年ではじく
          if date.year < corporate_holiday.year_from || date.year > corporate_holiday.year_to
            next
          end

          # 次に月ではじく
          if date.month != corporate_holiday.month
            next
          end

          # 一致を返却
          holiday = Date.new(date.year, corporate_holiday.month, corporate_holiday.day_or_week)
          if date == holiday
            return true
          end
        end

        return false
      end

      def logger
        ::Rails.logger
      end

    end
  end
end

unless Redmine::Utils::DateCalculation.include? JozuGantt::UtilsPatch
  Redmine::Utils::DateCalculation.send(:include, JozuGantt::UtilsPatch)
end
