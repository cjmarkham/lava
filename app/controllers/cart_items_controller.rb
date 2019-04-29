class CartItemsController < ApplicationController
    include ApplicationHelper

    before_action :get_cart, only: :index

    def index
    end

    def create
        data = {
            data: {
                id: params[:product_id],
                type: 'cart_item',
                quantity: params[:quantity].to_i,
            }
        }

        create_result = MoltinRequest("/carts/#{session[:session_id]}/items", :post, data)

        if ! create_result.kind_of? Net::HTTPSuccess
            render json: create_result.body.to_json, status: 422
            return
        end

        render json: create_result.body.to_json, status: 201
    end

    def destroy
        destroy_result = MoltinRequest("/carts/#{session[:session_id]}/items/#{params[:id]}", :delete)
        render json: destroy_result.body.to_json
    end

    private

    def get_cart
        cart_result = MoltinRequest("/carts/#{session[:session_id]}", :get)
        if ! cart_result.kind_of? Net::HTTPSuccess
            raise cart_result.body.to_yaml
        end

        @cart = JSON.parse(cart_result.body)['data']
    end
end
