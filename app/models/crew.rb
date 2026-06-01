class Crew < ApplicationRecord
  self.table_name = "crew"

  belongs_to :title
end
