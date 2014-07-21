class Api::ComponentsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Component.active_objects.joins(:machine).where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Component.active_objects.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) 
        )
        
      }.count
      
    
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = Component.
                  where(:machine_id => params[:parent_id]).joins(:machine).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Component.where(:machine_id => params[:parent_id]).count 
    else
      
      @objects = Component.active_objects.joins(:machine).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Component.active_objects.count
    end
    
    
    
    # render :json => { :components => @objects , :total => @total, :success => true }
  end

  def create
    @object = Component.create_object( params[:component] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :components => [@object] , 
                        :total => Component.active_objects.count }  
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
    
    @object = Component.find_by_id params[:id] 
    @object.update_object( params[:component])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :components => [@object],
                        :total => Component.active_objects.count  } 
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
    @object = Component.find(params[:id])
    @object.delete_object

    if not  @object.persisted?
      render :json => { :success => true, :total => Component.active_objects.count }  
    else
      render :json => { :success => false, :total => Component.active_objects.count }  
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    selected_parent_id = params[:parent_id]
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      if params[:parent_id].nil?
        @objects = Component.active_objects.joins(:machine).where{ (name =~ query)   
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")

        @total = Component.active_objects.where{ (name =~ query)  
                                }.count
      else
        @objects = Component.active_objects.joins(:machine).where{ 
                            (machine_id.eq selected_parent_id  ) & 
                            (name =~ query)   
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")

        @total = Component.active_objects.where{ 
                            (machine_id.eq selected_parent_id  ) & 
                            (name =~ query)
                                }.count
      end
      
                              
  
    else
      
      
      @objects = Component.active_objects.joins(:machine).where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Component.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
