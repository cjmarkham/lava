class BrandsController < ApplicationController
    include ApplicationHelper

    before_action :get_brand, only: :show

    def show
        limit, offset = get_pagination
        uri = "/products?filter=eq(brand.id,#{@brand['id']})&include=main_image&page[limit]=#{limit}&page[offset]=#{offset}"

        products_result = MoltinRequest(uri, :get)
        if ! products_result.kind_of? Net::HTTPSuccess
            raise InternalServerError.new(products_result.body)
        end

        products_data = JSON.parse(products_result.body)
        @products = {data: [], included: products_data['included'], links: products_data['links'], meta: products_data['meta']}

        # Some jiggery pokery: Setting to not pull child products
        # doesnt work when a filter is applied to request
        products_data['data'].each do |product|
            if product['relationships']['parent']
                next
            end

            @products[:data].push product

            # now we need to get the inventory of each product
            # since the products service stock level doesnt reflect
            # actual stock
            uri = "/inventories/#{product['id']}"
            inventory_result = MoltinRequest(uri, :get)
            if ! inventory_result.kind_of? Net::HTTPSuccess
                raise InternalServerError.new(inventory_result.body)
            end

            product['stock'] = JSON.parse(inventory_result.body)['data']['available']
        end
    end

    private

    def get_brand
        uri = "/brands/#{params[:id]}"
        brand_result = MoltinRequest(uri, :get)
        if ! brand_result.kind_of? Net::HTTPSuccess
            raise InternalServerError.new(brand_result.body)
        end

        @brand = JSON.parse(brand_result.body)['data']
    end

    def get_pagination
        limit = params[:limit].to_i || 10
        offset = params[:page] ? (params[:page].to_i - 1 || 1) * limit : 0

        return limit, offset
    end
end
