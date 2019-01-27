class Vendor < ActiveRecord::Base
  VALID_OUI_REGEX = /\A[\da-fA-F]{6}\z/
  validates :name, presence: true
  validates :oui, presence: true,
                  format: { with: VALID_OUI_REGEX },
                  uniqueness: true
  def oui=(val)
    write_attribute :oui, val.upcase
  end
end
