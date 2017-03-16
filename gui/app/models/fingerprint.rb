class Fingerprint < ActiveRecord::Base
  self.per_page = 10
  validates :name, presence: :true,
            uniqueness: { case_sensitive: false }
  validate :tcp_ports, if: :valid_TCP_ports
  validate :udp_ports, if: :valid_UDP_ports
  validate :shares, if: :contains_no_invalid_chars
  
  def valid_TCP_ports
    if tcp_ports
      valid_ports(tcp_ports)
    end
  end
  
  def valid_UDP_ports
    if udp_ports
      valid_ports(udp_ports)
    end
  end
  
  def valid_ports(ports)
    ports.split.map {|s| s.to_i.abs }.each {|port| errors.add(:port, "must be a number 1-65535") if port < 1 or port > 65535 }
  end
  
  def contains_no_invalid_chars
    if shares =~ /[<>:"\/\0\?\*|\\]/
      errors.add(:share, 'Invalid share in shares')
    end
  end
end
