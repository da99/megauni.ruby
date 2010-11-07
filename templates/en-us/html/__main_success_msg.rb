show_if 'success_msg' do
  div.success_msg {
    div.title 'Success.'
    div.msg( "{{success_msg}}" )
  } # div.success_msg
end 


if @partial
  partial @partial
end
