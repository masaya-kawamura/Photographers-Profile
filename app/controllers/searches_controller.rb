class SearchesController < ApplicationController

  def search
    @photographers = Photographer.search(params[:word])
    render 'searches/index'
  end

end
