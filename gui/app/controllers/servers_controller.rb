class ServersController < ApplicationController
  def index
    @search = Server.search(params[:q])
    @servers = @search.result.paginate(page: params[:page])
  end
  
  def edit
    @server = Server.find(params[:id])
  end

  def update
    @server = Server.find(params[:id])
    if @server.update_attributes(server_params)
      flash[:success] = "Server updated"
      redirect_to servers_path
    else
      render 'edit'
    end
  end 
  
  def new
    @server = Server.new
  end

  def create
    @server = Server.new(server_params)
    if @server.save
      flash[:success] = "Added new server #{@server.name}"
      redirect_to servers_path
    else
      flash[:danger] = 'Error'
      render 'new'
    end
  end

  def destroy
    @server = Server.find(params[:id])
    @server.destroy
    flash[:success] = "Deleted server named '#{@server.name}'."
    redirect_to servers_path
  end
  
  private
    def server_params
      params.require(:server).permit(:name, :ip)
    end
end
