
require 'time' # To use Time.parse.

class News 

  include CouchPlastic

  # ==== CONSTANTS =====================================================
  
  

  # ==== ERRORS ========================================================
  

  # ==== ASSOCIATIONS ==================================================
  # one_to_many :taggings, :class_name=>'NewsTagging', :key=>:news_id
  # one_to_many :tags, :class_name=>'NewsTag', :dataset=> proc { 
  #   NewsTag.filter(:id=>taggings_dataset.select(:id))
  # }

  # ==== HOOKS =========================================================


  # ==== CLASS METHODS =================================================

  def self.create editor, raw_data
    doc = new
    doc.validate_editor editor, :ADMIN
    doc.title= raw_data
    doc.body= raw_data 
    doc.published_at = raw_data
    doc.set_optional_values raw_data, :teaser, :published_at, :tags
    doc.save_create :set_created_at
    doc
  end

  def self.edit editor, raw_data
    doc = find_by_id_or_raise(raw_data[:id])
    doc.validate_editor(editor, :ADMIN)
    doc
  end

  def self.update editor, raw_data
    doc = edit(editor, raw_data)
    doc.set_optional_values raw_data, :title, :body, :teaser, :published_at, :tags
    doc.save_update :set_updated_at
    doc
  end


  # ==== INSTANCE METHODS ==============================================

  def last_modified_at
    updated_at || created_at
  end

  def title= raw_data
    fn = :title
    new_title = raw_data[:title].to_s.strip
    if new_title.empty?
      self.errors << "Title must not be empty."
      return nil
    end
    self.new_values[:title] = new_title
  end # === 

  def teaser= raw_data
    new_teaser = raw_data[:teaser].to_s.strip
    if new_teaser.empty?
      new_values[:teaser] = nil
    else
      new_values[:teaser] = new_teaser 
    end
  end # ===

  def body= raw_data
    new_body = raw_data[:body].to_s.strip
    if new_body.empty?
      self.errors << "Body must not be empty."
    elsif new_body.length < 10
      self.errors << "Body is too short. Write more."
    end

    return nil if !self.errors.empty?

    new_values[:body] = new_body
  end # ===

  def published_at= raw_data
    self.new_values[:published_at] = Time.parse(raw_data[:published_at]) || Time.now.utc
  end

  def tags= raw_data
    new_tags = raw_data[:tags].to_s.split
    return nil if new_tags.empty?
    self.new_values[:tags] = new_tags
  end

end # === end News
