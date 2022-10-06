# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

class TableInfo
  attr_reader :localized_header_pattern
  
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
    
    #   @schema.reject { |_col_name, column_val|
    #   column_val[:null] || column_val[:auto_increment] || column_val[:default].present?
    # }.keys
  end

  def length_limit_data(headers)
    # header_with_language = headers.select { |x| x.match(/\[en\]|\[zh\]/) }
    # header_with_language.each do |header|
    #   header_without_language = header.split('[')[0]
    #   limit = @schema["#{header_without_language}"][:limit] || 255
    #   @header_with_limit << [header, limit]
    # end
    # @header_with_limit

    multi_lan_headers = headers.select { |header| /[a-zA-Z]+\[[a-z]+\]/.match(header) }

    headers
      .select { |header| multi_lan_headers.include?(header) }
      .map { |header|
        header_only = header.split('[')[0]
        limit = @schema[header_only][:limit].presence || 255
       p [header, limit]
      }

  end

  private
  def timestamp_type
    %w[timestamp datetime]
  end
end

