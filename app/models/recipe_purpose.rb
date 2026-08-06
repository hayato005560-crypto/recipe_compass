class RecipePurpose < ApplicationRecord
  belongs_to :recipe
  belongs_to :purpose
end
