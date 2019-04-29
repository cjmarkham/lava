class CurrenciesController < ApplicationController
    def set_currency
        @currency = session[:currency] = params[:code]
        render plain: 'success', status: 200
    end
end
