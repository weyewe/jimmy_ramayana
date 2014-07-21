class Api::ItemsController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      
      if params[:parent_id].present? and params[:parent_id].length != 0
        livesearch = "%#{params[:livesearch]}%"
        @objects = Item.active_objects.joins(:item_type).where{ 
          (item_type_id.eq params[:parent_id]) & 
          (
            (description =~  livesearch ) | 
            (sku =~  livesearch )
          )

        }.page(params[:page]).per(params[:limit]).order("id DESC")

        @total = Item.where{ 
          (item_type_id.eq params[:parent_id]) & 
          (
            (description =~  livesearch ) | 
            (sku  =~  livesearch )
          )
        }.count
      else
        livesearch = "%#{params[:livesearch]}%"
        @objects = Item.active_objects.joins(:item_type).where{ 
          (
            (description =~  livesearch ) | 
            (sku =~  livesearch )
          )

        }.page(params[:page]).per(params[:limit]).order("id DESC")

        @total = Item.where{ 
          (
            (description =~  livesearch ) | 
            (sku  =~  livesearch )
          )
        }.count
      end
      
      
    else
      if params[:parent_id].present? and params[:parent_id].length != 0
        @objects = Item.active_objects.where(:item_type_id => params[:parent_id]).joins(:item_type).
                    page(params[:page]).per(params[:limit]).order("id DESC")
        @total = Item.active_objects.where(:item_type_id => params[:parent_id]).count
      else
        @objects = Item.active_objects.joins(:item_type).
                    page(params[:page]).per(params[:limit]).order("id DESC")
        @total = Item.active_objects.count
      end
      
      
    end
    
  end

  def create
    @object = Item.create_object( params[:item] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :items => [@object] , 
                        :total => Item.active_objects.count }  
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
    
    @object = Item.find_by_id params[:id] 
    @object.update_object( params[:item])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :items => [@object],
                        :total => Item.active_objects.count  } 
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
    @object = Item.find(params[:id])
    @object.delete_object

    if  @object.errors.size == 0 
      render :json => { :success => true, :total => Item.active_objects.count }  
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
    selected_parent_id = params[:parent_id]
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      if params[:parent_id].nil? or params[:parent_id].length == 0 
        @objects = Item.where{ 
                              (sku =~ query)  | 
                              (description =~ query)
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")

        @total = Item.where{ 
                (sku =~ query)  | 
                (description =~ query)
                                }.count
      else
        component = Component.find_by_id params[:parent_id]
        item_compatibility_list = component.compatibilities.map{|x| x.item_id}
        
        @objects = Item.joins(:compatibilities).where{ 
                              ( id.in item_compatibility_list ) &
                              (
                                (sku =~ query)  | 
                                (description =~ query)
                              )
                              
                              
                                }.
                          page(params[:page]).
                          per(params[:limit]).
                          order("id DESC")

        @total = Item.joins(:compatibilities).where{ 
                    ( id.in item_compatibility_list ) &
                    (
                      (sku =~ query)  | 
                      (description =~ query)
                    )
                                }.count
      end
      
    else
      @objects = Item.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Item.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
