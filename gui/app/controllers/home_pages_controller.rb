class HomePagesController < ApplicationController
  def index
    @devices = Device.paginate(page: params[:page])
  end

  def r2d2
    @leases = Lease.paginate(page: params[:page])
  end

  def l2s2
    #code
  end
end
