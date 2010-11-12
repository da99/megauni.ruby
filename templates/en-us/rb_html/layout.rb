text(%~<?xml version="1.0" encoding="UTF-8"?>~)

declare!(:DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")

tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en" ) {

  head {
  
    meta( :'http-equiv'=>"Content-Script-Type" , :content=>"text/javascript" )
    meta( :'http-equiv'=>"Content-Style-Type"  , :content=>"text/css" )
    meta( :'http-equiv'=>"Content-Language"    , :content=>"en-US" )
    meta( :'http-equiv'=>"Content-Type"        , :content=>"text/html; charset=utf-8" )
    meta( :'http-equiv'=>"Content-Language"    , :content=>"en-US" )
    
    # if_not 'meta_cache?' do
    #   meta( :'http-equiv'=>'expires' , :content=>'Thu, 12 Mar 2004 12:34:12 GMT' )
    # end

    loop 'meta_menu' do
      meta( :name=>'{{name}}', :content=>"{{content}}")
    end

    as 'page' do
      title( "{{title}}" )
    end

    link( :rel=>"shortcut icon", :href=>"/favicon.ico", :type=>"image/x-icon")
    
    if_not("mobile_request?") {
      link( 
        :rel=>"stylesheet",  
        :href=>"{{css_file}}?time=#{Time.now.utc.to_i}", 
        :media=>"screen", 
        :type=>"text/css" 
      )
    }
    
    mustache "head_content"
   
  } # === head

  body.the_body! {
    
    # partial '__flash_msg'
    
    # ================= the_content ================================
    div.the_content! {
      partial( @template_name )
    }
    # ==============================================================

    javascript_files.each do |file_hash|
      script '', file_hash
    end
    
    # mustache 'javascripts' do
    #   script '', :src=>'{{src}}?{{time_i}}', :type=>'text/javascript'
    # end

    show_if 'include_tracking?' do
      text %~
        <script type="text/javascript"> var mp_protocol = (('https:' == document.location.protocol) ? 'https://' : 'http://'); document.write(unescape('%3Cscript src="' + mp_protocol + 'api.mixpanel.com/site_media/js/api/mixpanel.js" type="text/javascript"%3E%3C/script%3E')); </script> 
        <script type="text/javascript"> try {  var mpmetrics = new MixpanelLib('86bbd0a09d702cd9eef7ba93d59dca93'); } catch(err) { null_fn = function () {}; var mpmetrics = {  track: null_fn,  track_funnel: null_fn,  register: null_fn,  register_once: null_fn, register_funnel: null_fn }; } </script>
        <script type="text/javascript">mpmetrics.track("eveything", { 'referer' : '{{http_referer}}' });</script>
      ~
    end
  } # the_body
}


 


