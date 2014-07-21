class Api::PurchaseOrdersController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = PurchaseOrder.active_objects.where{
        (
          (description =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = PurchaseOrder.active_objects.where{
        (
          (description =~  livesearch ) 
        )
        
      }.count
    else
      @objects = PurchaseOrder.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = PurchaseOrder.active_objects.count
    end
    
    
    
    # render :json => { :purchase_orders => @objects , :total => @total, :success => true }
  end

  def create
    
    params[:purchase_order][:purchase_date] = parse_date_from_client_booking( params[:purchase_order][:purchase_date] ) 
    @object = PurchaseOrder.create_object( params[:purchase_order] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_orders => [
                            :id            =>  @object.id             , 
                            :contact_id    =>   @object.contact_id,
                            :contact_name  => @object.contact.name , 
                            :purchase_date => format_date_friendly( @object.purchase_date ),
                            :description   => @object.description ,
                            :is_confirmed  => @object.is_confirmed, 
                            :confirmed_at  =>  format_date_friendly( @object.confirmed_at )
                          ] , 
                        :total => PurchaseOrder.active_objects.count }  
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
    
    params[:purchase_order][:purchase_date] = parse_date( params[:purchase_order][:purchase_date] )
    params[:purchase_order][:confirmed_at] = parse_date( params[:purchase_order][:confirmed_at] ) 
    
    @object = PurchaseOrder.find_by_id params[:id] 
    
    if params[:confirm].present?  
      
      if not current_user.has_role?( :purchase_orders, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.confirm_object(:confirmed_at => params[:purchase_order][:confirmed_at] )
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :purchase_orders, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.unconfirm_object 
    else
      @object.update_object(params[:purchase_order])
    end
     
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_orders => [
                          :id            =>  @object.id             , 
                          :contact_id    =>   @object.contact_id,
                          :contact_name  => @object.contact.name , 
                          :purchase_date => format_date_friendly( @object.purchase_date ),
                          :description   => @object.description ,
                          :is_confirmed  => @object.is_confirmed, 
                          :confirmed_at  =>  format_date_friendly( @object.confirmed_at )

                          ],
                        :total => PurchaseOrder.active_objects.count  } 
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
    @object = PurchaseOrder.find_by_id params[:id] 
    render :json => { :success => true, 
                      :purchase_orders => [
                        :id            =>  @object.id             , 
                        :contact_id    =>   @object.contact_id,
                        :contact_name  => @object.contact.name , 
                        :purchase_date => format_date_friendly( @object.purchase_date ),
                        :description   => @object.description ,
                        :is_confirmed  => @object.is_confirmed, 
                        :confirmed_at  =>  format_date_friendly( @object.confirmed_at )


                        	
                        ] , 
                      :total => PurchaseOrder.active_objects.count }
  end

  def destroy
    @object = PurchaseOrder.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => PurchaseOrder.active_objects.count }  
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
      @objects = PurchaseOrder.active_objects.where{ 
        (description =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = PurchaseOrder.active_objects.where{
          (description =~ query)    
                              }.count
    else
      @objects = PurchaseOrder.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = PurchaseOrder.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
