Rails.application.routes.draw do
    root 'home#index'

    resources :brands
    resources :products
    post 'currencies', to: 'currencies#set_currency'

    resources :cart_items, only: [:create, :destroy, :index]
    get 'cart', to: 'cart_items#index'
    post 'checkout', to: 'carts#checkout'
    post 'carts/apply_promotion', to: 'carts#apply_promotion'
end
