# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

class TableInfo
  attr_reader :localized_header_pattern
  # def localized_header_pattern
  #    @localized_header_pattern
  #  end
  def initialize(schema)
    @schema = schema
    @header_with_limit = []

  end

  def timestamp_columns
    @schema.select{|_col_name, col_type|
                  timestamp_type.include?(col_type[:type])}
                  .keys
  end

  def not_null_columns
    @schema.select{|_col_name, col_type| 
                  !col_type[:null] && !col_type[:auto_increment] && !col_type[:default] }
                  .keys

  end

  def length_limit_data(headers)
    header_with_language = headers.select { |x| x.match(/\[en]|\[zh]/) }
    header_with_language.each do |header|
      header_without_language = header.split('[')[0]
      limit = @schema["#{header_without_language}"][:limit]
      @header_with_limit << [header, limit]
    end
    @header_with_limit

  end

  private
  def timestamp_type
    %w[timestamp datetime]
  end
end

