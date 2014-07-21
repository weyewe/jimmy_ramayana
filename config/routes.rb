Ticketie::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'
  
  get 'awesome_image' => 'home#awesome_image', :as => :awesome_image, :method => :get
  
  
  
  namespace :api do
    devise_for :users
    post 'authenticate_auth_token', :to => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token 
    put 'update_password' , :to => "passwords#update" , :as => :update_password
    get 'search_role' => 'roles#search', :as => :search_role, :method => :get
    get 'search_user' => 'app_users#search', :as => :search_user, :method => :get
    get 'search_item_type' => 'item_types#search', :as => :search_item_type, :method => :get
    get 'search_item' => 'items#search', :as => :search_item, :method => :get
    get 'search_customer' => 'customers#search', :as => :search_customer, :method => :get
    get 'search_warehouse' => 'warehouses#search', :as => :search_warehouse, :method => :get
    get 'search_contact' => 'contacts#search', :as => :search_contact, :method => :get
    get 'search_purchase_order' => 'purchase_orders#search', :as => :search_purchase_order, :method => :get
    get 'search_purchase_order_detail' => 'purchase_order_details#search', :as => :search_purchase_order_detail, :method => :get
    get 'search_sales_order' => 'sales_orders#search', :as => :search_sales_order, :method => :get
    get 'search_sales_order_detail' => 'sales_order_details#search', :as => :search_sales_order_detail, :method => :get
    get 'search_machine' => 'machines#search', :as => :search_machine, :method => :get
    get 'search_component' => 'components#search', :as => :search_component, :method => :get
    get 'search_asset' => 'assets#search', :as => :search_asset, :method => :get
    
    # master data 
    resources :warehouses
    resources :app_users
    resources :customers 
    resources :item_types  
    resources :items 
    
    resources :maintenances
    resources :maintenance_details 
    
    resources :contacts 
    resources :machines
    resources :components 
    resources :compatibilities
    
    resources :stock_adjustments
    resources :stock_adjustment_details
    
    resources :purchase_orders
    resources :purchase_order_details 
    
    resources :purchase_receivals
    resources :purchase_receival_details 
    
    resources :sales_orders
    resources :sales_order_details 
    
    resources :delivery_orders
    resources :delivery_order_details
    resources :assets
    
    resources :asset_details
    
    
  end
  
  
end
