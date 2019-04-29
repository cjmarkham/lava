require 'net/http'

class ApplicationController < ActionController::Base
    class InternalServerError < StandardError; end

    include ApplicationHelper

    before_action :get_currency
    before_action :get_access_token
    before_action :get_currencies
    before_action :get_cart_items
    before_action :get_brands

    rescue_from InternalServerError, with: :internal_server_error

    def get_currency
        @currency ||= session[:currency] || 'GBP'
    end

    def get_access_token
        data = {
            grant_type: 'client_credentials',
            client_id: ENV['MOLTIN_CLIENT_ID'],
            client_secret: ENV['MOLTIN_CLIENT_SECRET']
        }
        token_result = MoltinRequest('/oauth/access_token', :post, data, true)
        if ! token_result.kind_of? Net::HTTPSuccess
            raise InternalServerError.new(token_result.body)
        end

        @access_token ||= JSON.parse(token_result.body)['access_token']
    end

    def get_cart_items
        items_result = MoltinRequest("/carts/#{session[:session_id]}/items", :get)
        if ! items_result.kind_of? Net::HTTPSuccess
            raise items_result.body.to_yaml
        end

        @cart_items = JSON.parse(items_result.body)['data']
        @cart_items_count = 0
        @cart_items.each do |item|
            @cart_items_count += item['quantity']
        end
    end

    def get_brands
        brands_result = MoltinRequest('/brands', :get)
        if ! brands_result.kind_of? Net::HTTPSuccess
            raise InternalServerError.new(brands_result.body)
        end

        @brands = JSON.parse(brands_result.body)['data']
    end

    def get_currencies
        currencies_request = MoltinRequest('/currencies', :get)
        if ! currencies_request.kind_of? Net::HTTPSuccess
            raise InternalServerError.new(currencies_request.body)
        end

        @currencies = JSON.parse(currencies_request.body)['data']
    end

    def internal_server_error err
        @err = err
        render 'errors/internal_server_error'
    end
end
