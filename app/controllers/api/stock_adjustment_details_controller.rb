class Api::StockAdjustmentDetailsController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      # livesearch = "%#{params[:livesearch]}%"
      #  @objects = StockAdjustmentDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #    
      #  }.page(params[:page]).per(params[:limit]).order("id DESC")
      #  
      #  @total = StockAdjustmentDetail.where{ 
      #    (
      #      (name =~  livesearch ) | 
      #      (code =~  livesearch )
      #    )
      #  }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = StockAdjustmentDetail.
                  where(:stock_adjustment_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = StockAdjustmentDetail.where(:stock_adjustment_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :stock_adjustment_details => @objects , :total => @total, :success => true }
  end

  def create
    @object = StockAdjustmentDetail.create_object( params[:stock_adjustment_detail] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :stock_adjustment_details => [@object] , 
                        :total => StockAdjustmentDetail.active_objects.count }  
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
    
    @object = StockAdjustmentDetail.find_by_id params[:id] 
    @object.update_object( params[:stock_adjustment_detail])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :stock_adjustment_details => [@object],
                        :total => StockAdjustmentDetail.active_objects.count  } 
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
    @object = StockAdjustmentDetail.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => StockAdjustmentDetail.active_objects.count }  
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
  #     @objects = StockAdjustmentDetail.joins(:stock_adjustment_detail_type).where{ 
  #                           (stock_adjustment_detail_type.name =~ query)   | 
  #                           (code =~ query)  | 
  #                           (description =~ query)
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #                       
  #     @total = StockAdjustmentDetail.joins(:stock_adjustment_detail_type).where{ 
  #             (stock_adjustment_detail_type.name =~ query)   | 
  #             (code =~ query)  | 
  #             (description =~ query)
  #                             }.count
  #   else
  #     @objects = StockAdjustmentDetail.where{ (id.eq selected_id)  
  #                             }.
  #                       page(params[:page]).
  #                       per(params[:limit]).
  #                       order("id DESC")
  #  
  #     @total = StockAdjustmentDetail.where{ (id.eq selected_id)   
  #                             }.count 
  #   end
  #   
  #   
  #   # render :json => { :records => @objects , :total => @total, :success => true }
  # end
end
