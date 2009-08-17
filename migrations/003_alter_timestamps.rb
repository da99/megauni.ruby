class AlterTimestamps < Sequel::Migration

  def up
    set_column_type :issues, :created_at, :"timestamp with time zone"      
    set_column_type :mini_issues, :created_at, :"timestamp with time zone"        
  end

  def down
    if table_exists?(:issues)
      set_column_type :issues, :created_at, :"timestamp without time zone"      
    end
    if table_exists?(:mini_issues)
      set_column_type :mini_issues, :created_at, :"timestamp without time zone"  
    end
  end

end # ---------- end CreateMembers
