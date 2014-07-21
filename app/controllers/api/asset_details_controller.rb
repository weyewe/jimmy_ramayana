class Api::AssetDetailsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = AssetDetail.where{ 
        (
          (code =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = AssetDetail.where{ 
        (
          (code =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = AssetDetail.
                  where(:asset_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = AssetDetail.where(:asset_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :asset_details => @objects , :total => @total, :success => true }
  end

  def create
    @object = AssetDetail.create_object( params[:asset_detail] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :asset_details => [@object] , 
                        :total => AssetDetail.active_objects.count }  
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
    
    @object = AssetDetail.find_by_id params[:id] 
    @object.assign_initial_item( params[:asset_detail])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :asset_details => [@object],
                        :total => AssetDetail.active_objects.count  } 
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
    @object = AssetDetail.find_by_id params[:id] 
    @objects = [@object]
    @total = 1 
      # 
      #   render :json => { :success => true, 
      #                     :asset_details => [
      #                         :id              =>  @object.id             , 
      #                         :warehouse_id    =>  @object.warehouse_id   , 
      #                         :warehouse_name  =>  @object.warehouse.name , 
      #                         :sales_order_id  =>  @object.sales_order_id , 
      #                         :is_confirmed    =>  @object.is_confirmed   ,  
      #                         :is_deleted      =>  @object.is_deleted     , 
      #                         :description     =>  @object.description    ,       
      #                         :delivery_date =>  format_date_friendly( @object.delivery_date )  ,  
      #                         :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
      #                         
      #                         
      #                       ] , 
      #                     :total => DeliveryOrder.active_objects.count }
  end

  def destroy
    @object = AssetDetail.find(params[:id])
    @object.delete_object

    if @object.is_deleted
      render :json => { :success => true, :total => AssetDetail.active_objects.count }  
    else
      render :json => { :success => false, :total => AssetDetail.active_objects.count }  
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
      @objects = AssetDetail.joins(:machine, :contact).where{ 
                            (machine.name =~ query)   | 
                            (code =~ query)  | 
                            (contact.name =~ query)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = AssetDetail.joins(:asset_detail_type).where{ 
              (machine.name =~ query)   | 
              (code =~ query)  | 
              (contact.name =~ query)
                              }.count
    else
      @objects = AssetDetail.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = AssetDetail.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
