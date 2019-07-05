# frozen_string_literal: true

module Validator
  def self.character?(text)
    if !text.nil?
      !text.delete("\n").delete("\r").empty?
    else
      false
    end
  end
end
