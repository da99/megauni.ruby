# VIEW ~/megauni/views/Messages_doc_log.rb
# SASS ~/megauni/templates/en-us/css/Messages_doc_log.sass
# NAME Messages_doc_log

div.logs {

  show_if("no_logs?") {
    div.empty_msg 'No updates have been made.'
  }
  
  loop('logs') {

    div.log {
      span.created_at '{{created_at}}'
      span.author {
        a '{{editor_username}}', :href=>'{{editor_href}}'
      }
      span.diff '{{compiled_diff}}'
    }

  } # === loop

} # === div.logs

