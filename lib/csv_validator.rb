require 'csv'
require 'active_support'
require 'active_support/core_ext'

class CsvValidator
  attr_reader :errors

  def initialize(file_path, table_info, locales: [])
    @table_info = table_info
    @csv = CSV.table(file_path, { header_converters: lambda { |header| header.to_s } })
    @errors = []
  end

  def valid?
    check_empty
    check_duplicate_id
    check_not_null
    check_time
    check_length_limit
    @errors.empty?
  end

  private
  def check_empty
    @errors << "Empty Content" if @csv.empty?
  end
  
  def check_duplicate_id
    dup_id = @csv["id"].select{|elm| @csv["id"].count(elm) > 1}.uniq
    @errors << "Duplicate Ids: #{dup_id}" if dup_id.present?
  end
  
  def check_not_null
    @table_info.not_null_columns.each do |col|
      @csv[col].each.with_index(1) do |value, index|
        @errors << "Not Null Violation at #{col} in Row ID=#{index}" if value.nil?
      end
    end
  end
  
  def check_time
    @table_info.timestamp_columns.each do |col|
      @csv[col].each.with_index(1) do |value, index|
        @errors <<  "Time Format Violation at #{col} in Row ID=#{index}" if (DateTime.parse(value) rescue ArgumentError) == ArgumentError
      end
    end
  end

  def check_length_limit
    @table_info.length_limit_data(@csv.headers).each do |col|
      @csv.each.with_index(1) do |value, index| 
      limit = col[1]
      value = value[col[0]]
      @errors << "Length Limit Violation at #{col[0]}(#{col[1]}) in Row ID=#{index}" if value.length > limit
      end
    end
  end
end

