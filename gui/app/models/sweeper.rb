class Sweeper < ActiveRecord::Base
  require 'resolv'
  self.per_page = 10
  #VALID_MAC_REGEX = /\A[\da-f]{2}:[\da-f]{2}:[\da-f]{2}:[\da-f]{2}:[\da-f]{2}:[\da-f]{2}\z/i
  VALID_MAC_REGEX = /\A[\da-f]{12}\z/i
  validates :mac, presence: true,
                  format: { with: VALID_MAC_REGEX },
                  uniqueness: { case_sensitive: false }
  validates :ip, format: { :with => Resolv::IPv4::Regex },
                 allow_nil: true,
                 allow_blank: true

  def mac=(val)
    write_attribute :mac, val.upcase.gsub(/[-:\.]/,'')
  end
  
end
