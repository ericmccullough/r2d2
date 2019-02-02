class PrefsController < ApplicationController
  def show
    @pref = Pref.first
    @separators = @pref.mac_separators.split('').map { |s| [s,s] } #[[':', ':'], ['-', '-'], ['.', '.']]
  end
  
  def update
    @pref = Pref.first
    if @pref.update_attributes(pref_params)
      flash[:success] = "Preference updated"
      redirect_to root_path
    else
      flash[:error] = "Preference update FAILED"
      render 'show'
    end
  end
  
  private
    def pref_params
      params.require(:pref).permit(:mac_separator, :mac_uppercase)
    end
end
