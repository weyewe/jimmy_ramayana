class Api::MaintenancesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Maintenance.active_objects.joins( :warehouse, :asset => [:machine]).where{
        (
          (code =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Maintenance.active_objects.where{
        (
          (code =~  livesearch ) 
        )
        
      }.count
    else
      @objects = Maintenance.active_objects.joins( :warehouse ,:asset => [:machine]).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Maintenance.active_objects.count
    end
    
    
    
    # render :json => { :maintenances => @objects , :total => @total, :success => true }
  end

  def create
    
    params[:maintenance][:complaint_date] = parse_date_from_client_booking( params[:maintenance][:complaint_date] ) 
    @object = Maintenance.create_object( params[:maintenance] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :maintenances => [
                            :id            =>  @object.id             , 
                            :contact_id    =>   @object.asset.contact_id,
                            :contact_name  => @object.asset.contact.name , 
                            :complaint_date => format_date_friendly( @object.complaint_date ),
                            :complaint   => @object.complaint ,
                            :is_confirmed  => @object.is_confirmed, 
                            :confirmed_at  =>  format_date_friendly( @object.confirmed_at )
                          ] , 
                        :total => Maintenance.active_objects.count }  
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
    
    params[:maintenance][:complaint_date] = parse_date( params[:maintenance][:complaint_date] )
    params[:maintenance][:confirmed_at] = parse_date( params[:maintenance][:confirmed_at] ) 
    
    @object = Maintenance.find_by_id params[:id] 
    
    if params[:confirm].present?  
      
      if not current_user.has_role?( :maintenances, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.confirm(:confirmed_at => params[:maintenance][:confirmed_at] )
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :maintenances, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.unconfirm
    else
      @object.update_object(params[:maintenance])
    end
     
     
    if @object.errors.size == 0 
      
      @total =  Maintenance.active_objects.count
      @objects = [@object]
      # render :json => { :success => true,   
      #                    :maintenances => [
      #                      :id            =>  @object.id             , 
      #                      :contact_id    =>   @object.contact_id,
      #                      :contact_name  => @object.contact.name , 
      #                      :complaint_date => format_date_friendly( @object.complaint_date ),
      #                      :description   => @object.description ,
      #                      :is_confirmed  => @object.is_confirmed, 
      #                      :confirmed_at  =>  format_date_friendly( @object.confirmed_at )
      # 
      #                      ],
      #                    :total => Maintenance.active_objects.count  } 
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
    @object = Maintenance.find_by_id params[:id] 
    @total = Maintenance.active_objects.count
    @objects = [@object]
    # render :json => { :success => true, 
    #                     :maintenances => [
    #                       :id            =>  @object.id             , 
    #                       :contact_id    =>   @object.asset.contact_id,
    #                       :contact_name  => @object.asset.contact.name , 
    #                       :complaint_date => format_date_friendly( @object.complaint_date ),
    #                       :complaint   => @object.complaint ,
    #                       :is_confirmed  => @object.is_confirmed, 
    #                       :confirmed_at  =>  format_date_friendly( @object.confirmed_at ),
    #                       :code => @object.asset.code ,
    #                       :warehouse_id => @object.warehouse_id,
    #                       :warehouse_name => @object.warehouse.name 
    #                         
    #                       ] , 
    #                     :total => Maintenance.active_objects.count }
  end

  def destroy
    @object = Maintenance.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => Maintenance.active_objects.count }  
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
      @objects = Maintenance.active_objects.joins(:asset, :warehouse).where{ 
        (code =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = Maintenance.active_objects.where{
          (code =~ query)    
                              }.count
    else
      @objects = Maintenance.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Maintenance.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
