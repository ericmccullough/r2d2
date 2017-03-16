class FingerprintsController < ApplicationController
  def index
    @search = Fingerprint.search(params[:q])
    @fingerprints = @search.result.paginate(page: params[:page])
  end
  
  def new
    @fingerprint = Fingerprint.new
  end

  def create
    @fingerprint = Fingerprint.new(fingerprint_params)
    if @fingerprint.save
      flash[:success] = "Added new fingerprint #{@fingerprint.name}"
      redirect_to fingerprints_path
    else
      flash[:danger] = 'Error'
      render 'new'
    end
  end
  
  def edit
    @fingerprint = Fingerprint.find(params[:id])
  end

  def update
    @fingerprint = Fingerprint.find(params[:id])
    if @fingerprint.update_attributes(fingerprint_params)
      flash[:success] = "Fingerprint updated"
      redirect_to fingerprints_path
    else
      render 'edit'
    end
  end

  def destroy
    @fingerprint = Fingerprint.find(params[:id])
    @fingerprint.destroy
    flash[:success] = "Deleted fingerprint named '#{@fingerprint.name}'."
    redirect_to fingerprints_path
  end
  
  private
    def fingerprint_params
      params.require(:fingerprint).permit(:name, :tcp_ports, :udp_ports, :shares)
    end
end