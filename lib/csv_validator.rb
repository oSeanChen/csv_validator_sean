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
    check_empty(@csv)
    check_duplicate_id(@csv)
    check_not_null(@csv)
    check_time(@csv)


    @errors.empty?
  end

  private
  def check_empty(data)
    @errors << "Empty Content" if data.empty?
  end
  
  def check_duplicate_id(data)
    dup_id = data["id"].select{|elm| data["id"].count(elm) > 1}.uniq
    if data["id"].length == data["id"].uniq.length
      true
    else
      @errors << "Duplicate Ids: #{dup_id}"
    end
  end
  def check_not_null(data)
    @table_info.not_null_columns.each do |col|
      data[col].each_with_index do |value, index|
        @errors << "Not Null Violation at #{col} in Row ID=#{index + 1}" if value.nil?
      end
    end
  end
  def check_time(data)
    @table_info.timestamp_columns.each do |col|
      data[col].each_with_index do |value, index|
        @errors <<  "Time Format Violation at #{col} in Row ID=#{index + 1}" if (DateTime.parse(value) rescue ArgumentError) == ArgumentError
      end
    end
  end
end

