class Lease < ActiveRecord::Base
  require 'resolv'
  validates :ip, presence: true,
                 format: { :with => Resolv::IPv4::Regex },
                 uniqueness: true
  validates :device, presence: true
  validates :expiration, presence: true
  belongs_to :scope
  belongs_to :device, dependent: :destroy
  accepts_nested_attributes_for :device
  self.per_page = 10
  
  after_create do
    begin
      if self.device.created_at.to_i >= (self.created_at.to_i - 1)
        foundb4 = 'N'
      else
        foundb4 = 'Y'
      end
      vendor = Vendor.find_by(oui: self.device.mac[0..5]).name
      logger.info "\{'r2d2':\{'sensor':'d1s2','scope':'#{self.scope.ip}',"+
                  "'mac':'#{self.device.mac}','dhcp-host':'#{self.name}',"+
                  "'IP':'#{self.ip}','Timestamp':'#{self.created_at}',"+
                  "'Found_before':'#{foundb4}','Lease':'','Vendor':'#{vendor}'\}\}"
    rescue
    end
  end
end
