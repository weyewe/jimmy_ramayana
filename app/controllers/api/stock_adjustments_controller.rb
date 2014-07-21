class Api::StockAdjustmentsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = StockAdjustment.active_objects.where{
        (
          (description =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = StockAdjustment.active_objects.where{
        (
          (description =~  livesearch ) 
        )
        
      }.count
    else
      @objects = StockAdjustment.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = StockAdjustment.active_objects.count
    end
    
    
    
    # render :json => { :stock_adjustments => @objects , :total => @total, :success => true }
  end

  def create
    
    params[:stock_adjustment][:adjustment_date] = parse_date_from_client_booking( params[:stock_adjustment][:adjustment_date] ) 
    @object = StockAdjustment.create_object( params[:stock_adjustment] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :stock_adjustments => [
                            :id              =>  @object.id             , 
                            :warehouse_id    =>  @object.warehouse_id   , 
                            :warehouse_name  =>  @object.warehouse.name , 
                            :is_confirmed    =>  @object.is_confirmed   ,  
                            :is_deleted      =>  @object.is_deleted     , 
                            :description     =>  @object.description    ,       
                            :adjustment_date =>  format_date_friendly( @object.adjustment_date )  ,  
                            :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
                          ] , 
                        :total => StockAdjustment.active_objects.count }  
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
    
    params[:stock_adjustment][:adjustment_date] = parse_date( params[:stock_adjustment][:adjustment_date] )
    params[:stock_adjustment][:confirmed_at] = parse_date( params[:stock_adjustment][:confirmed_at] ) 
    
    @object = StockAdjustment.find_by_id params[:id] 
    
    if params[:confirm].present?  
      
      if not current_user.has_role?( :stock_adjustments, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.confirm_object(:confirmed_at => params[:stock_adjustment][:confirmed_at] )
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :stock_adjustments, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.unconfirm_object 
    else
      @object.update_object(params[:stock_adjustment])
    end
     
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :stock_adjustments => [
                          :id              =>  @object.id             , 
                          :warehouse_id    =>  @object.warehouse_id   , 
                          :warehouse_name  =>  @object.warehouse.name , 
                          :is_confirmed    =>  @object.is_confirmed   ,  
                          :is_deleted      =>  @object.is_deleted     , 
                          :description     =>  @object.description    ,       
                          :adjustment_date =>  format_date_friendly( @object.adjustment_date )  ,  
                          :confirmed_at    =>  format_date_friendly( @object.confirmed_at )

                          ],
                        :total => StockAdjustment.active_objects.count  } 
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
    @object = StockAdjustment.find_by_id params[:id] 
    render :json => { :success => true, 
                      :stock_adjustments => [
                          :id              =>  @object.id             , 
                          :warehouse_id    =>  @object.warehouse_id   , 
                          :warehouse_name  =>  @object.warehouse.name , 
                          :is_confirmed    =>  @object.is_confirmed   ,  
                          :is_deleted      =>  @object.is_deleted     , 
                          :description     =>  @object.description    ,       
                          :adjustment_date =>  format_date_friendly( @object.adjustment_date )  ,  
                          :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
                        	
                        	
                        ] , 
                      :total => StockAdjustment.active_objects.count }
  end

  def destroy
    @object = StockAdjustment.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => StockAdjustment.active_objects.count }  
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
      @objects = StockAdjustment.active_objects.where{ (description =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = StockAdjustment.active_objects.where{ (description =~ query)  
                              }.count
    else
      @objects = StockAdjustment.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = StockAdjustment.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
