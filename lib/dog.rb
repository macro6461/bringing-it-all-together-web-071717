require 'pry'
class Dog

  # ATTRIBUTES = {}

  attr_accessor :name, :breed, :id
  # attr_reader :id

  @@all = []

  def self.all
    @@all
  end
  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
    @@all << self
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", name, breed)
    new_dog_save = DB[:conn].execute("SELECT id FROM dogs WHERE dogs.name = ? AND dogs.breed = ?", name, breed)
    self.id = new_dog_save[0][0]
    self
  end

  def self.find_by_id(id)
  dog_from_db = self.all.find do |dog|
      dog.id == id
    end
    return dog_from_db
  end

  def self.find_by_breed(breed)
    DB[:conn].execute("SELECT * FROM dogs WHERE dogs.breed = ?", breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(params)
    new_doggo = Dog.new(params)
    new_doggo.save
    new_doggo
  end

  def self.find_or_create_by(name:, breed:)
    # self.find_by_breed(params[:breed]) ? self.find_by_breed(params[:breed]) : self.create(params)
    # binding.pry
    new_doggo_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    if !new_doggo_array.empty?
      dog_data = new_doggo_array[0]
      new_doggo = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      new_doggo = self.create(name: name, breed: breed)
    end
      # binding.pry

      # new_doggo = Dog.new(id: new_doggo_array[0][0], name: new_doggo_array[0][1], breed: new_doggo_array[0][2])
    new_doggo
    # binding.pry
    # new_doggo = Dog.new(id: new_doggo_array[0][0], name: new_doggo_array[0][1], breed: new_doggo_array[0][2])
  end

  def self.new_from_db(row)
    # binding.pry
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def update
      sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  # Pry.start

end
