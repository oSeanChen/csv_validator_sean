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
    # TODO, add any initialize process if you need

  end

  def timestamp_columns
    # TODO
    @schema.select{|_col_name, col_type|
                  timestamp_type.include?(col_type[:type])}
                  .keys
  end

  def not_null_columns
    # TODO
    @schema.select{|_col_name, col_type| 
                  !col_type[:null] && !col_type[:auto_increment] && !col_type[:default] }
                  .keys

  end

  def length_limit_data(headers)
    # TODO
  end

  private
  # TODO, implement any private methods you need
  def timestamp_type
    %w[timestamp datetime]
  end
end

