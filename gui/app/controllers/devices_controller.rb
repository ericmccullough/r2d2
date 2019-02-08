class DevicesController < ApplicationController
  def index
    @devices = Device.paginate(page: params[:page])
    @devices.each {|d| format_mac(d)}
  end

  def show
    @device = Device.find(params[:id])
    d = Sweep.includes(:devices).where(devices:{mac: @device.mac})
    @details = d.paginate(page: params[:page])
  end

  def update
    device = Device.find(params[:id])
    if params[:mac]
      device.mac.gsub!(/[^\da-f]/,'')
    end
    if params[:list]
      device.list = List.find(params[:list])
    end
    if params[:device]
      if params[:device][:notes]
        device.notes = params[:device][:notes]
      end
    end
    device.save
    redirect_to :back
  end
  #
  private
  #  def device_params
  #    params.require(:device).permit(:list, :notes)
  #  end

end
