require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.create(props)
    new_dog = Dog.new(props)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    found_dog = DB[:conn].execute(sql,id)[0]
    Dog.new(name:found_dog[1], breed:found_dog[2], id:id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    found_dog = DB[:conn].execute(sql,name)[0]
    Dog.new(name:found_dog[1], breed:found_dog[2], id:found_dog[0])
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.create(name: row[1], breed:row[2], id:row[3])
  end

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?,breed = ? WHERE id = ?",self.name,self.breed,self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
          INSERT INTO dogs (name,breed)
          VALUES (?,?)
        SQL
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


end # end of Dog class
