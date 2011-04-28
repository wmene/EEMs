ActionController::Routing::Routes.draw do |map|
  map.login "login", :controller => 'login', :action => 'new'
  
  # Copied from vendor/plugins/blacklight/lib/blacklight/routes.rb and modified for /view
  map.resources(:catalog, :as => 'view',
    :only => [:index, :show, :update],
    # /catalog/:id/image <- for ajax cover requests
    # /catalog/:id/status
    # /catalog/:id/availability
    :member=>{:image=>:get, :status=>:get, :availability=>:get, :citation=>:get, :send_email_record=>:post, :email=>:get, :sms=>:get},
    # /catalog/map
    :collection => {:map => :get, :opensearch=>:get}
  )
  
  # The priority is based upon order of creation: first created -> highest priority.
  Blacklight::Routes.build map
  
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect 'eems/:eems_id/log', :controller => 'log', :action => 'create'
  map.connect 'eems/:eems_id/submit_to_tech_services', :controller => 'submit_to_tech_services', :action => 'create'
  map.connect 'eems/no_pdf', :controller => 'eems', :action => 'no_pdf'
  
  map.resources :eems do |s|
    s.resources :permission_files
    s.resources :parts
  end
  map.resources :content_files

  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
