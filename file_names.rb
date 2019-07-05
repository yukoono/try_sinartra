# frozen_string_literal: true

module FileNames
  def self.fetch
    directry_name = Dir.pwd + "/memo"
    file_names = Dir.entries(directry_name)
    file_names.select! { |file_name| file_name[0] != "." }
  end
end
