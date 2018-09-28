require 'pry'
class Dog

  attr_accessor :name, :breed, :id
  # attr_reader :id

  def initialize(props={})
    # props.each {|k, v| self.send(("#{k}"), v)}
    @id = props[:id]
    # binding.pry
    @name = props[:name]
    @breed = props[:breed]
  end

  def self.create_table
    sql = "CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );"

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs;"

    DB[:conn].execute(sql)
  end

  def save

    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      sql2 = "SELECT last_insert_rowid() FROM dogs;"
      @id = DB[:conn].execute(sql2)[0][0]
    end
    self
  end

  def self.create(props)
    self.new(props).save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    # binding.pry
    array = DB[:conn].execute(sql, id).first
    self.new_from_db(array)
    # hash = {id: nil, name: nil, breed: nil}
    # # binding.pry
    # i = 0
    # doggo = hash.each {|k, v| hash[k] =
    #   array[i]
    #   i += 1}
    # # binding.pry
    # #   array.map {|e| e
    # #     binding.pry
    # #     }}
    # # binding.pry
    # self.create(doggo)
  end

  def self.find_or_create_by(array)
    doggo = self.new(array)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    if DB[:conn].execute(sql, doggo.name, doggo.breed) == []
      doggo = self.create(array)
    else
      doggo.id = DB[:conn].execute(sql, doggo.name, doggo.breed)[0][0]
      # binding.pry
    # else
    #   sql = "SELECT * FROM dogs WHERE "
    #   self.find_by_id(id)
    end
    doggo
  end

  def self.new_from_db(array)
    # hash = {id: nil, name: nil, breed: nil}
    # # i = 0
    # doggo = hash.each_with_index {|k, v, i| #getting error cant add new key into hash during iteration
    #   # binding.pry
    #   hash[k] = array[i]}
    # #   i += 1}
    # self.create(doggo)

    new_dog = self.new()
    # binding.pry
    new_dog.id = array[0]
    new_dog.name = array[1]
    new_dog.breed = array[2]
    new_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
