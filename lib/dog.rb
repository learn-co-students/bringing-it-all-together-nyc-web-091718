require 'pry'

# Dog
#   attributes
#     has a name and a breed
#     has an id that defaults to `nil` on initialization
#     accepts key value pairs as arguments to initialize
#   .create_table
#     creates the dogs table in the database
#   .drop_table
#     drops the dogs table from the database
# #save
#     returns an instance of the dog class (FAILED - 1)
#     saves an instance of the dog class to the database and then sets the given dogs `id` attribute (FAILED - 2)
#   .create
#     takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database (FAILED - 3)
#     returns a new dog object (FAILED - 4)
#   .find_by_id
#     returns a new dog object by id (FAILED - 5)
#   .find_or_create_by
#     creates an instance of a dog if it does not already exist (FAILED - 6)
#     when two dogs have the same name and different breed, it returns the correct dog (FAILED - 7)
#     when creating a new dog with the same name as persisted dogs, it returns the correct dog (FAILED - 8)
#   .new_from_db
#     creates an instance with corresponding attribute values (FAILED - 9)
#   .find_by_name
#     returns an instance of dog that matches the name from the DB (FAILED - 10)
#   #update
#     updates the record associated with a given instance (FAILED - 11)

class Dog
attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    dog_data = DB[:conn].execute(sql, id)[0]
    dog = Dog.new_from_db(dog_data)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    dog_data = DB[:conn].execute(sql, name)[0]
    dog = Dog.new_from_db(dog_data)
  end


  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
    result = DB[:conn].execute(sql, name, breed)
    if result.empty?
      new_dog = Dog.create(name: name, breed: breed)
    else
      new_dog_data = result[0]
      new_dog = Dog.new_from_db(new_dog_data)
    end
  end

end

# class Dog
#   attr_accessor :id, :name, :breed
#
#   def initialize(id: nil, name:, breed:)
#     @id = id
#     @name = name
#     @breed = breed
#     #self
#   end
#   def self.create_table
#     sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
#     DB[:conn].execute(sql)
#   end
#   def self.drop_table
#     sql = "DROP TABLE IF EXISTS dogs"
#     DB[:conn].execute(sql)
#   end
#   def update
#     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
#     DB[:conn].execute(sql, self.name, self.breed, self.id)
#     #binding.pry
#   end
#   def save
#     if self.id
#       self.update
#     else
#       sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
#       DB[:conn].execute(sql, self.name, self.breed)
#       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
#     end
#     self
#   end
#
#
#   def self.new_from_db(row)
#     new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
#   end
#   def self.find_by_name(name)
#     sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
#     result = DB[:conn].execute(sql, name)
#     result.map do |row|
#       Dog.new_from_db(row)
#     end.first
#   end
#   def self.find_by_id(id)
#     sql = "SELECT * FROM dogs WHERE id = ?;"
#     result = DB[:conn].execute(sql, id)
#     result.map do |row|
#       Dog.new_from_db(row)
#     end.first
#   end
#
#
#   def self.create(name:, breed:)
#     new_dog = Dog.new(name: name, breed: breed)
#     new_dog.save
#     new_dog
#   end
#   def self.find_or_create_by(name:, breed:)
#     sql = <<-SQL
#       SELECT *
#       FROM dogs
#       WHERE name = ? AND breed = ?
#       LIMIT 1
#     SQL
#     result = DB[:conn].execute(sql, name, breed)
#     if result.empty?
#       new_dog = self.create(name: name, breed: breed)
#     else
#       new_dog_data = result[0]
#       new_dog = Dog.new(id: new_dog_data[0], name: new_dog_data[1], breed: new_dog_data[2])
#     end
#     new_dog
#   end
#
# end
