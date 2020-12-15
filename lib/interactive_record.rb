require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names 
    DB[:conn].results_as_hash = true
   
    sql = "pragma table_info('#{table_name}')"
    
    table_info = DB[:conn].execute(sql)
    column_names = []
    
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact

  end
  

  def initialize(data={})
    data.each do |key, value|
      self.send("#{key}=", value)
    end 
  end 
  
  def table_name_for_insert
    self.class.table_name
  end 
  
  def col_names_for_insert
    self.class.column_names.select{|child_attribute| child_attribute!= "id"}.join(", ")
  end 
  
  def values_for_insert
    out = []
    self.class.column_names.each do |col_name|
      if(send(col_name)!= nil)
        out.push("\'#{send(col_name)}\'")
      end 
    end 
    out.join(", ")
  end
  
  def save
    sql = "INSERT INTO
      #{table_name_for_insert}
      (#{col_names_for_insert})
      VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

    

  
  def self.find_by_name(name)
    sql ="SELECT * FROM #{table_name} WHERE name = ?"

    DB[:conn].execute(sql, name)
  end 
  
  def self.find_by(data_hash)
    key = data_hash.keys[0]
    sql ="SELECT * FROM #{table_name} WHERE #{key} = ?"
    DB[:conn].execute(sql, data_hash[key])
  end
end