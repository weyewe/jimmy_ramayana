class Api::DeliveryOrderDetailsController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      # livesearch = "%#{params[:livesearch]}%"
      #  @objects = DeliveryOrderDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #    
      #  }.page(params[:page]).per(params[:limit]).order("id DESC")
      #  
      #  @total = DeliveryOrderDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #  }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = DeliveryOrderDetail.
                  where(:delivery_order_id => params[:parent_id]).
                  joins(:delivery_order, :sales_order_detail => [:item]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = DeliveryOrderDetail.where(:delivery_order_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :delivery_order_details => @objects , :total => @total, :success => true }
  end

  def create
    @object = DeliveryOrderDetail.create_object( params[:delivery_order_detail] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :delivery_order_details => [
                            :delivery_order_id       => @object.delivery_order_id, 
                            :sales_order_detail_id   => @object.sales_order_detail_id, 
                            :item_id                    => @object.sales_order_detail.item.id, 
                            :item_sku                   => @object.sales_order_detail.item.sku, 
                            :quantity                   => @object.quantity
                          
                          
                          ] , 
                        :total => DeliveryOrderDetail.where(:delivery_order_id => @object.delivery_order_id).active_objects.count }  
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
    
    @object = DeliveryOrderDetail.find_by_id params[:id] 
    @object.update_object( params[:delivery_order_detail])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_order_details => [
                            :delivery_order_id       => @object.delivery_order_id, 
                            :sales_order_detail_id   => @object.sales_order_detail_id, 
                            :item_id                    => @object.sales_order_detail.item.id, 
                            :item_sku                   => @object.sales_order_detail.item.sku, 
                            :quantity                   => @object.quantity
                          
                          ],
                        :total => DeliveryOrderDetail.active_objects.count  } 
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
    @object = DeliveryOrderDetail.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => DeliveryOrderDetail.active_objects.count }  
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
  
  # def search
  #   search_params = params[:query]
  #   selected_id = params[:selected_id]
  #   if params[:selected_id].nil?  or params[:selected_id].length == 0 
  #     selected_id = nil
  #   end
  #   
  #   query = "%#{search_params}%"
  #   # on PostGre SQL, it is ignoring lower case or upper case 
  #   
  #   if  selected_id.nil?
  #     @objects = DeliveryOrderDetail.joins(:delivery_order_detail_type).where{ 
  #                           (delivery_order_detail_type.name =~ query)   | 
  #                           (code =~ query)  | 
  #                           (description =~ query)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #                       
  #     @total = DeliveryOrderDetail.joins(:delivery_order_detail_type).where{ 
  #             (delivery_order_detail_type.name =~ query)   | 
  #             (code =~ query)  | 
  #             (description =~ query)
  #                             }.count
  #   else
  #     @objects = DeliveryOrderDetail.where{ (id.eq selected_id)  
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #  
  #     @total = DeliveryOrderDetail.where{ (id.eq selected_id)   
  #                             }.count 
  #   end
  #   
  #   
  #   # render :json => { :records => @objects , :total => @total, :success => true }
  # end
end
