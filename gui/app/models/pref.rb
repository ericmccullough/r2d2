class Pref < ActiveRecord::Base
  before_validation :default_values
  VALID_MAC_SEPARATOR = /[\-:\.]/
  validates :mac_separator, length: { maximum: 1 },
                            format: { with: VALID_MAC_SEPARATOR }

  def default_values
    self.mac_separator ||= ':'
    self.mac_separators ||= ':-.'
    if self.mac_uppercase.nil?
      self.mac_uppercase = true
    end
  end
end
