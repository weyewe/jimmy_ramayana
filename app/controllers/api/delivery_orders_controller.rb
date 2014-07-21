class Api::DeliveryOrdersController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = DeliveryOrder.active_objects.joins(:sales_order, :warehouse).where{
        (
          (description =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = DeliveryOrder.active_objects.where{
        (
          (description =~  livesearch ) 
        )
        
      }.count
    else
      @objects = DeliveryOrder.active_objects.joins(:sales_order, :warehouse).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = DeliveryOrder.active_objects.count
    end
    
    
    
    # render :json => { :delivery_orders => @objects , :total => @total, :success => true }
  end

  def create
    
    params[:delivery_order][:delivery_date] = parse_date_from_client_booking( params[:delivery_order][:delivery_date] ) 
    @object = DeliveryOrder.create_object( params[:delivery_order] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :delivery_orders => [
                            :id              =>  @object.id             , 
                            :sales_order_id => @object.sales_order_id, 
                            :delivery_date =>  format_date_friendly( @object.delivery_date )  ,  
                            :warehouse_id    =>  @object.warehouse_id   , 
                            :warehouse_name  =>  @object.warehouse.name , 
                            :is_confirmed    =>  @object.is_confirmed   ,  
                            :is_deleted      =>  @object.is_deleted     , 
                            :description     =>  @object.description    ,       
                            
                            :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
                          ] , 
                        :total => DeliveryOrder.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    
    params[:delivery_order][:delivery_date] = parse_date( params[:delivery_order][:delivery_date] )
    params[:delivery_order][:confirmed_at] = parse_date( params[:delivery_order][:confirmed_at] ) 
    
    @object = DeliveryOrder.find_by_id params[:id] 
    
    if params[:confirm].present?  
      
      if not current_user.has_role?( :delivery_orders, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.confirm_object(:confirmed_at => params[:delivery_order][:confirmed_at] )
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :delivery_orders, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.unconfirm_object 
    else
      @object.update_object(params[:delivery_order])
    end
     
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_orders => [
                          :id              =>  @object.id             , 
                          :sales_order_id => @object.sales_order_id, 
                          :warehouse_id    =>  @object.warehouse_id   , 
                          :warehouse_name  =>  @object.warehouse.name , 
                          :is_confirmed    =>  @object.is_confirmed   ,  
                          :is_deleted      =>  @object.is_deleted     , 
                          :description     =>  @object.description    ,       
                          :delivery_date =>  format_date_friendly( @object.delivery_date )  ,  
                          :confirmed_at    =>  format_date_friendly( @object.confirmed_at )

                          ],
                        :total => DeliveryOrder.active_objects.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg 
    end
  end
  
  def show
    @object = DeliveryOrder.find_by_id params[:id] 
    render :json => { :success => true, 
                      :delivery_orders => [
                          :id              =>  @object.id             , 
                          :warehouse_id    =>  @object.warehouse_id   , 
                          :warehouse_name  =>  @object.warehouse.name , 
                          :sales_order_id  =>  @object.sales_order_id , 
                          :is_confirmed    =>  @object.is_confirmed   ,  
                          :is_deleted      =>  @object.is_deleted     , 
                          :description     =>  @object.description    ,       
                          :delivery_date =>  format_date_friendly( @object.delivery_date )  ,  
                          :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
                        	
                        	
                        ] , 
                      :total => DeliveryOrder.active_objects.count }
  end

  def destroy
    @object = DeliveryOrder.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => DeliveryOrder.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = DeliveryOrder.active_objects.where{ (description =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = DeliveryOrder.active_objects.where{ (description =~ query)  
                              }.count
    else
      @objects = DeliveryOrder.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = DeliveryOrder.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
