class Api::AssetsController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Asset.where{ 
        (
          (code =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Asset.where{ 
        (
          (code =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = GroupLoan.find_by_id params[:parent_id]
      @objects = Asset.
                  where(:contact_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Asset.where(:contact_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :assets => @objects , :total => @total, :success => true }
  end

  def create
    @object = Asset.create_object( params[:asset] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :assets => [@object] , 
                        :total => Asset.active_objects.count }  
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
    
    @object = Asset.find_by_id params[:id] 
    @object.update_object( params[:asset])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :assets => [@object],
                        :total => Asset.active_objects.count  } 
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
    @object = Asset.find(params[:id])
    @object.delete_object

    if @object.is_deleted
      render :json => { :success => true, :total => Asset.active_objects.count }  
    else
      render :json => { :success => false, :total => Asset.active_objects.count }  
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
      @objects = Asset.joins(:machine, :contact).where{ 
                            (machine.name =~ query)   | 
                            (code =~ query)  | 
                            (contact.name =~ query)
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = Asset.joins(:machine, :contact).where{ 
              (machine.name =~ query)   | 
              (code =~ query)  | 
              (contact.name =~ query)
                              }.count
    else
      @objects = Asset.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Asset.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
