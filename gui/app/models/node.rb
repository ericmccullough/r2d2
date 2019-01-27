class Node < ActiveRecord::Base
  require 'resolv'
  has_many :results
  has_many :sweeps, through: :results
  self.per_page = 10
  #VALID_MAC_REGEX = /\A[\da-f]{2}:[\da-f]{2}:[\da-f]{2}:[\da-f]{2}:[\da-f]{2}:[\da-f]{2}\z/i
  VALID_MAC_REGEX = /\A[\da-f]{12}\z/i
  validates :mac, presence: true,
                  format: { with: VALID_MAC_REGEX }
  validates :ip, presence: true,
                 format: { :with => Resolv::IPv4::Regex }

  def mac=(val)
    begin
      write_attribute :mac, val.upcase.gsub(/[-:\.]/,'')
    rescue
    end
  end
  
  def vendor
    begin
      vendor_name = Vendor.find_by(oui: self.mac[0..5]).name
    rescue
      if !vendor_name
        vendor_name = 'UNKNOWN'
      end
    end
    vendor_name
  end
end
