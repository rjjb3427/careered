module Api
  class ListsController < ApplicationController
    def index
      render json: current_user.lists
    end

    def show
      render json: current_user.lists.find(params[:id])
    end

    def create
    	list = List.new(list_params)
    	if list.save
    		render json: list, status: :ok
      else
    		render json: list.errors, status: :unprocessable_entity
    	end
    end

    def update
      list = current_user.lists.find(params[:id])
      if list.update_attributes(list_params)
        render json: list, status: :ok
      else
        render json: list.errors, status: :unprocessable_entity
      end
    end

    def destroy
      list = current_user.lists.find(params[:id])
			if list.destroy
				render json: list, status: :ok
			else
				render json: list.errors, status: :unprocessable_entity
			end
    end

    def sort
      list_ids = params[:list].map(&:to_i)

      unless (list_ids - current_user.list_ids).empty?
      	render nothing: true, status: :unprocessable_entity
      end

      list_ids.each_with_index do |id, index|
        List.update_all({ position: index + 1 }, { id: id })
      end

      # return re-sorted lists
      render json: current_user.lists.reload
    end

    private
    def list_params
      params.require(:list).permit!
    end
  end
end
