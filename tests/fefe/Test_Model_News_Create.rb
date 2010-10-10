

class News_Create < Test::Unit::TestCase

  must 'only allow Admins as creators' do
    assert_raise(Mongo_Dsl::Unauthorized) do
      News.create(regular_member_1, {})
    end
  end

  must 'require title' do
    doc = begin
            News.create( 
              admin_mem, 
              :club   =>'club-hearts',
              :title  => nil,
              :teaser => 'My Teaser.',
              :body   => 'The Body',
              :published_at => nil
             )
          rescue News::Invalid => e
            e.doc
          end

    assert_equal(
      "Title is required.", 
      doc.errors.first
    )
  end

  must 'require body' do
    doc = begin
            News.create( 
              admin_mem, 
              :club   =>'club-hearts',
              :title  => 'My News',
              :teaser => 'My Teaser.',
              :body   => nil,
              :published_at => nil
             )
          rescue News::Invalid => e
            e.doc
          end

    assert_equal(
      "Body is required.", 
      doc.errors.first
    )
  end

  must 'set published_at to now as a default' do
    doc = News.create( 
      admin_mem, 
      :club   =>'club-hearts',
      :title  => 'My News',
      :teaser => 'My Teaser.',
      :body   => 'My body.',
      :published_at => nil
    )

    assert_equal(
      chop_last_2(utc_string), 
      chop_last_2(doc.data.published_at)
    )
  end

  must 'split tag string on new lines' do
    doc = News.create( 
      admin_mem, 
      :club   =>'club-hearts',
      :title  => 'My News',
      :teaser => 'My Teaser.',
      :body   => 'My body.',
      :tags   => "t1\nt2\nt3",
      :published_at => nil
    )

    assert_equal(
      %w{ t1 t2 t3 }, 
      doc.data.tags.sort
    )
  end

  must 'strip each tag' do 
    doc = News.create( 
      admin_mem, 
      :club   =>'club-hearts',
      :title  => 'My News',
      :teaser => 'My Teaser.',
      :body   => 'My body.',
      :tags   => "t1  \n \n \nt2  \n  \n  t3",
      :published_at => nil
    )

    assert_equal %w{ t1 t2 t3 }, doc.data.tags.sort
  end

  must 'reject any empty tag' do
    doc = News.create( 
      admin_mem, 
      :club   =>'club-hearts',
      :title  => 'My News',
      :teaser => 'My Teaser.',
      :body   => 'My body.',
      :tags   => "tag1\n\n\ntag2\n\ntag3",
      :published_at => nil
    )

    assert_equal %w{ tag1 tag2 tag3 }, doc.data.tags.sort
  end

end # === class News_Create
