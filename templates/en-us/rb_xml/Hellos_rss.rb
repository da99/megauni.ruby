instruct! :xml, :version => '1.0'
rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  channel do
    self << %~<atom:link href="{{site_url}}rss.xml" rel="self" type="application/rss+xml" />~
    title '{{site_title}}'
    description '{{site_tag_line}}'
    self.link '{{site_url}}'
    
    self << "{{# posts }}"
      item {
        title '{{title}}'
        self.link  '{{url}}'
        description '{{body}}'
        pubDate "{{published_at_rfc822}}"
        guid "{{url}}"
      }
    self << '{{/posts}}'
  end
end
