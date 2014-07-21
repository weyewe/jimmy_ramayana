class Api::PurchaseOrderDetailsController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      # livesearch = "%#{params[:livesearch]}%"
      #  @objects = PurchaseOrderDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #    
      #  }.page(params[:page]).per(params[:limit]).order("id DESC")
      #  
      #  @total = PurchaseOrderDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #  }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = PurchaseOrderDetail.
                  where(:purchase_order_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = PurchaseOrderDetail.where(:purchase_order_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :purchase_order_details => @objects , :total => @total, :success => true }
  end

  def create
    @object = PurchaseOrderDetail.create_object( params[:purchase_order_detail] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_order_details => [@object] , 
                        :total => PurchaseOrderDetail.active_objects.count }  
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
    
    @object = PurchaseOrderDetail.find_by_id params[:id] 
    @object.update_object( params[:purchase_order_detail])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_order_details => [@object],
                        :total => PurchaseOrderDetail.active_objects.count  } 
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

  def destroy
    @object = PurchaseOrderDetail.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => PurchaseOrderDetail.active_objects.count }  
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
    selected_parent_id = params[:parent_id]
    
    if  selected_id.nil?
      if params[:parent_id].nil?
        @objects = PurchaseOrderDetail.joins(:item).where{ 
                              (item.sku =~ query)   |  
                              (item.description =~ query)
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")

        @total = PurchaseOrderDetail.joins(:item).where{ 
                              (item.sku =~ query)   |  
                              (item.description =~ query)
                                }.count
      else
        @objects = PurchaseOrderDetail.joins(:item).where{ 
                              ( purchase_order_id.eq selected_parent_id) & 
                              (
                                (item.sku =~ query)   |  
                                (item.description =~ query)
                              )
          
                              
                      }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")

        @total = PurchaseOrderDetail.joins(:item).where{ 
                        ( purchase_order_id.eq selected_parent_id) & 
                        (
                          (item.sku =~ query)   |  
                          (item.description =~ query)
                        )
              }.count
      end
      
      
    else
      @objects = PurchaseOrderDetail.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = PurchaseOrderDetail.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
