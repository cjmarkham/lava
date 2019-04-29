class CartsController < ApplicationController
    def checkout
        data = {
            data: {
                customer: {
                    name: params[:first_name] << ' ' << params[:last_name],
                    email: params[:email],
                },
                billing_address: {
                    first_name: params[:first_name],
                    last_name: params[:last_name],
                    line_1: params[:address_1],
                    line_2: params[:address_2],
                    county: params[:county],
                    country: params[:county],
                    postcode: params[:post_code],
                },
                shipping_address: {
                    first_name: params[:first_name],
                    last_name: params[:last_name],
                    line_1: params[:address_1],
                    line_2: params[:address_2],
                    county: params[:county],
                    country: params[:county],
                    postcode: params[:post_code],
                }
            }
        }

        checkout_result = MoltinRequest("/carts/#{session[:session_id]}/checkout", :post, data)
        body = JSON.parse(checkout_result.body)

        if ! checkout_result.kind_of? Net::HTTPSuccess
            flash[:error] = body['errors']
            redirect_back fallback_location: root_path
            return
        end

        pay_for_order body
    end

    def apply_promotion
        data = {
            data: {
                type: 'promotion_item',
                code: params[:code],
            }
        }
        promotion_result = MoltinRequest("/carts/#{session[:session_id]}/items", :post, data)

        if ! promotion_result.kind_of? Net::HTTPSuccess
            render json: promotion_result.body.to_json, status: 422
            return
        end

        render json: promotion_result.body.to_json, status: 201
    end

    private

    def pay_for_order order
        data = {
            data: {
                gateway: 'stripe',
                method: 'purchase',
                payment: params[:token],
                options: {
                    receipt_email: params[:email],
                }
            }
        }
        payment_result = MoltinRequest("/orders/#{order['data']['id']}/payments", :post, data)

        if ! payment_result.kind_of? Net::HTTPSuccess
            flash[:error] = JSON.parse(payment_result.body)['errors']
            redirect_back fallback_location: root_path
            return
        end

        delete_cart
    end

    def delete_cart
        delete_request = MoltinRequest("/carts/#{session[:session_id]}", :delete)

        flash[:success] = 'Thank you for your purchase, come again!'
        redirect_to root_path
    end
end
