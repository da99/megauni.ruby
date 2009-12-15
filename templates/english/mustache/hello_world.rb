 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
   <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
   <meta http-equiv="Content-Script-Type" content="text/javascript"/>
   <meta http-equiv="Content-Style-Type" content="text/css"/>
   <meta http-equiv="Content-Language" content="en-US"/>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
   <meta http-equiv="Content-Language" content="en-US"/>
   <meta http-equiv="expires" content="Thu, 12 Mar 2004 12:34:12 GMT"/>
   <meta http-equiv="pragma" content="no-cache"/>
   <meta name="description" content="{{meta_description}}"/>
   <meta name="keywords" content="{{meta_keywords}}"/>
   <title>{{title}}</title>
   <link type="image/x-icon" href="{{full_uri}}/favicon.ico" rel="shortcut icon"/>
{{#mobile_request?}}   <link type="text/css" href="{{css_file}}" rel="stylesheet" media="screen"/>
{{/mobile_request?}}{{head_content}}  </head>
  <body id="the_body">
   <div id="container">
    <div id="timestamp">{{js_epoch_time}}</div>

{{#loading}}

    <div id="loading">Loading...</div>

{{/loading}}

    <p>Hello, {{world}}</p>
    <div id="footer">
     <span>(c) {{copyright_year}} {{site_domain}}. Some rights reserved.</span>
    </div>
{{javascripts}}   </div>
  </body>
 </html>
