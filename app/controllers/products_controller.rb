class ProductsController < ApplicationController
    before_action :get_product

    def show
        # Child products dont get images included
        if @product['included']['main_images']
            @image = @product['included']['main_images'][0]['link']['href']
        end

        # now we need to get the inventory of the product
        # since the products service stock level doesnt reflect
        # actual stock
        uri = URI ENV['MOLTIN_BASE_URL'].dup << "/inventories/#{@product['data']['id']}"

        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            req = Net::HTTP::Get.new uri
            req['AUTHORIZATION'] = "Bearer: #{@access_token}"
            res = http.request req

            @product['stock'] = JSON.parse(res.body)['data']['available']
        end
    end

    private

    def get_product
        uri = URI ENV['MOLTIN_BASE_URL'].dup << "/products/#{params[:id]}?include=main_image&sort=created_at"

        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            req = Net::HTTP::Get.new uri
            req['AUTHORIZATION'] = "Bearer: #{@access_token}"
            res = http.request req

            @product = JSON.parse(res.body)
        end
    end
end
