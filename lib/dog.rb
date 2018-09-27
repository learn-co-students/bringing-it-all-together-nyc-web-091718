class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def self.create_table
    sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def self.create(properties={})
    dog = Dog.new(properties)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?;
    SQL
    dog_row = DB[:conn].execute(sql, id)[0]
    dog_property_hash = {:id => dog_row[0], :name => dog_row[1], :breed => dog_row[2]}
    Dog.new(dog_property_hash)
  end

  def self.find_by_name(name)
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    properties_hash = {:id => dog_row[0], :name => dog_row[1], :breed => dog_row[2]}
    Dog.new(properties_hash)
  end

  def self.find_or_create_by(properties={})
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dogs = DB[:conn].execute(sql, properties[:name], properties[:breed])
    if dogs[0]
      Dog.find_by_id(dogs[0][0])
    else
      Dog.create(properties)
    end
  end

  def self.new_from_db(row)
    properties_hash = {:id => row[0], :name => row[1], :breed => row[2]}
    Dog.new(properties_hash)
  end

  def initialize(properties={})
    @name = properties[:name]
    @breed = properties[:breed]
    @id = properties[:id]
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end


end
