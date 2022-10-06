# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

class TableInfo
  attr_reader :localized_header_pattern
  
  def initialize(schema)
    @schema = schema

  end

  def timestamp_columns
    @schema.select{|_col_name, col_val|
                  timestamp_type.include?(col_val[:type])}
                  .keys
  end

  def not_null_columns
    @schema.select{|_col_name, col_val| 
                  !col_val[:null] && !col_val[:auto_increment] && !col_val[:default] }
                  .keys
  end

  def length_limit_data(headers)
    header_with_lan = headers.select { |header| header.match(/[a-zA-Z]+\[[a-z]+\]/) }
    header_with_lan.map {|header| 
      header_only = header.split("[")[0]
      limit = @schema[header_only][:limit].presence || 255
      [header, limit]
    }
  end

  private
  def timestamp_type
    %w[timestamp datetime]
  end
end

