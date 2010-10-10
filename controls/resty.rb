helpers {

  # === Use the following actions in your views. ===============================


  # === The following actions are used only by Resty actions. ============================
  # === They are not meant to be used by regular actions. ================================

  def rest_must_be_allowed!(action)
    opt_name = "#{clean_room[:model].to_s.underscore}_actions" 
    pass if !options.target.respond_to?(opt_name)
    pass if !options.send(opt_name).include?(action)
  end

  def require_model_class!
    pass if !clean_room[:model]
    begin
      model_class
    rescue NameError
      pass
    end
  end

  def require_model_instance!
    require_model_class!
    pass if !model_instance
  end

  def model_class
    @model_class ||= Object.const_get(clean_room[:model].underscore.camelize)
  end

  def model_instance 
    @model_instance ||= begin
      i = if clean_room[:id] 
        begin
          Mongo_Dsl.GET(Integer(clean_room[:id]))
        rescue model_class::Not_Found
          nil
        end
      end

      if i
        instance_variable_set "@#{clean_room[:model]}".to_sym, i
      end
      i
    rescue ArgumentError
      nil
    end
  end

  def rest_new! klass
    @model_class = klass
    require_log_in! if !model_class.creator?(:STRANGER)
    pass if !model_class.creator?(current_member)
    describe klass.to_s.underscore.to_sym, :new
  end

  def rest_edit!(klass)
    @model_class = klass
    require_log_in!
    require_model_instance!
    pass if !model_instance.updator?(current_member)
    describe klass.to_s.underscore.to_sym, :edit
  end

} # === helpers

get '/:model/new/' do  # :new
  rest_must_be_allowed! :new
  require_model_class!
  require_log_in! if !model_class.creator?(:STRANGER)
  pass if !model_class.creator?(current_member)

  describe clean_room[:model], :new
  render_mab
end

post '/:model/' do  # :create
  rest_must_be_allowed! :create
  require_model_class!

  begin
    n = model_class.creator current_member, clean_room
    flash.success_msg = ( " %s was saved." % english_name( n ).capitalize )
    redirect( "/#{clean_room[:model]}/#{n[:id]}/" )
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{clean_room[:model]}/new/")
  end

end # === post


get '/:model/:id/' do # :show
  rest_must_be_allowed! :show
  require_model_instance!
  dev_log_it "Resty :show action."

  require_log_in! if !model_instance.reader? :STRANGER
  pass if !model_instance.reader?(current_member)

  describe clean_room[:model], :show
  render_mab
end

get '/:model/:id/edit/' do # :edit
  rest_must_be_allowed! :edit
  require_log_in!
  require_model_instance!
  pass if !model_instance.updator?(current_member)

  describe clean_room[:model], :edit
  render_mab
end

put '/:model/:id/' do # :update
  rest_must_be_allowed! :update
  require_log_in!
  require_model_instance!

  begin
    n = model_class.updator current_member, clean_room
    flash.success_msg = ( "%s was saved. " % english_name(n).capitalize )
    redirect( request.path_info )
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect( File.join( request.path_info , "edit/" ) )
  end

end # === put

delete '/:model/:id/' do # delete
  rest_must_be_allowed! :delete
  require_log_in!
  require_model_instance!
  
  begin
    n = model_instance.deletor current_member, clean_room 
    flash.success_msg = "Deletion was successful."
    redirect( "/" )
  end

end # === delete




__END__
get '/:model/:id/' do
  validate_as_resty!
  eval("@#{clean_room[:model]} = current_resty[:instance]")
  render_mab
end

get '/:model/new/' do
  validate_as_resty!
  render_mab
end

post '/:model/' do 
  
  validate_as_resty! 
  n = current_resty[:instance]  
  begin
    flash.success_msg = ( " %s was saved." % english_name( n ).capitalize )
    redirect( "/#{n.class.to_s.underscore}/#{n[:id]}/")
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{n.class.to_s.underscore}/new/")
  end

end # === post

put '/:model/:id/' do

  validate_as_resty!
  n = current_resty[:instance]
  begin
    flash.success_msg = ( " %s was save. " % english_name(n).capitalize )
    redirect( "/#{n.class.to_s.underscore}/#{clean_room[:id]}" )
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{n.class.to_s.underscore}/#{clean_room[:id]}/edit/")
  end
end

delete '/:model/:id/' do
  validate_as_resty!
  current_resty[:instance].destroy
  flash.success_msg = "Deletion was successful."
end
