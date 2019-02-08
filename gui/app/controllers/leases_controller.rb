class LeasesController < ApplicationController
  def index
    @search = Lease.search(params[:q])
    @leases = @search.result.includes(:device, scope:[:server]).paginate(page: params[:page])
    @leases.each {|d| format_mac(d)}
  end

  def show
    @lease = Lease.includes(scope:[:server]).find(params[:id])
    format_mac(@lease)
  end
  
  private
  def format_mac(lease)
    separator = Pref.first.mac_separator
    lease.device.mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
    unless Pref.first.mac_uppercase
      if lease.device.mac.index(/[A-F]/)
        lease.device.mac.downcase!
      end
    end
    lease
  end
end
