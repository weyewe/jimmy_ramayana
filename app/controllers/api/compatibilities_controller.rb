class Api::CompatibilitiesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Compatibility.joins(:component).active_objects.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Compatibility.active_objects.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) 
        )
        
      }.count
    elsif params[:parent_id].present?
      # @component_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = Compatibility.joins(:component).active_objects.
                  where(:component_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Compatibility.active_objects.where(:component_id => params[:parent_id]).count 
    else
      @objects = Compatibility.joins(:component).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Compatibility.active_objects.count
    end
    
    # render :json => { :compatibilities => @objects , :total => @total, :success => true }
  end

  def create
    @object = Compatibility.create_object( params[:compatibility] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :compatibilities => [@object] , 
                        :total => Compatibility.active_objects.count }  
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
    
    @object = Compatibility.find_by_id params[:id] 
    @object.update_object( params[:compatibility])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :compatibilities => [@object],
                        :total => Compatibility.active_objects.count  } 
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
    @object = Compatibility.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => Compatibility.active_objects.count }  
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
      @objects = Compatibility.joins(:item, :component).active_objects.where{ 
                        (item.name =~ query)   |
                        (component.name =~ query )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = Compatibility.active_objects.where{ 
                            (item.name =~ query)   |
                            (component.name =~ query )
                              }.count
    else
      @objects = Compatibility.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Compatibility.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
