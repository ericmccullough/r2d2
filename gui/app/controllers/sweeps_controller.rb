class SweepsController < ApplicationController
  def index
    @sweeps = Sweep.paginate(page: params[:page])
  end
  
  def show
    @sweep = Sweep.find(params[:id])
    node_list = @sweep.nodes
    @nodes = node_list.paginate(page: params[:page])
    @nodes.each {|n| format_mac(n)}
  end
  
  private
    def format_mac(node)
      separator = Pref.first.mac_separator
      node.mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
      unless Pref.first.mac_uppercase
        if node.mac.index(/[A-F]/)
          node.mac.downcase!
        end
      end
      node
    end
end
