class Api::PurchaseReceivalDetailsController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      # livesearch = "%#{params[:livesearch]}%"
      #  @objects = PurchaseReceivalDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #    
      #  }.page(params[:page]).per(params[:limit]).order("id DESC")
      #  
      #  @total = PurchaseReceivalDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #  }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = PurchaseReceivalDetail.
                  where(:purchase_receival_id => params[:parent_id]).
                  joins(:purchase_receival, :purchase_order_detail => [:item]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = PurchaseReceivalDetail.where(:purchase_receival_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :purchase_receival_details => @objects , :total => @total, :success => true }
  end

  def create
    @object = PurchaseReceivalDetail.create_object( params[:purchase_receival_detail] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_receival_details => [
                            :purchase_receival_id       => @object.purchase_receival_id, 
                            :purchase_order_detail_id   => @object.purchase_order_detail_id, 
                            :item_id                    => @object.purchase_order_detail.item.id, 
                            :item_sku                   => @object.purchase_order_detail.item.sku, 
                            :quantity                   => @object.quantity
                          
                          
                          ] , 
                        :total => PurchaseReceivalDetail.where(:purchase_receival_id => @object.purchase_receival_id).active_objects.count }  
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
    
    @object = PurchaseReceivalDetail.find_by_id params[:id] 
    @object.update_object( params[:purchase_receival_detail])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_receival_details => [
                            :purchase_receival_id       => @object.purchase_receival_id, 
                            :purchase_order_detail_id   => @object.purchase_order_detail_id, 
                            :item_id                    => @object.purchase_order_detail.item.id, 
                            :item_sku                   => @object.purchase_order_detail.item.sku, 
                            :quantity                   => @object.quantity
                          
                          ],
                        :total => PurchaseReceivalDetail.active_objects.count  } 
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
    @object = PurchaseReceivalDetail.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => PurchaseReceivalDetail.active_objects.count }  
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
  #     @objects = PurchaseReceivalDetail.joins(:purchase_receival_detail_type).where{ 
  #                           (purchase_receival_detail_type.name =~ query)   | 
  #                           (code =~ query)  | 
  #                           (description =~ query)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #                       
  #     @total = PurchaseReceivalDetail.joins(:purchase_receival_detail_type).where{ 
  #             (purchase_receival_detail_type.name =~ query)   | 
  #             (code =~ query)  | 
  #             (description =~ query)
  #                             }.count
  #   else
  #     @objects = PurchaseReceivalDetail.where{ (id.eq selected_id)  
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #  
  #     @total = PurchaseReceivalDetail.where{ (id.eq selected_id)   
  #                             }.count 
  #   end
  #   
  #   
  #   # render :json => { :records => @objects , :total => @total, :success => true }
  # end
end
