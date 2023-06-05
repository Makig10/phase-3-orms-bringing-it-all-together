require 'sqlite3'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB.execute <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
  end

  def self.drop_table
    DB.execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    if self.id
      update
    else
      DB.execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
      self.id = DB.last_insert_row_id
    end
    self
  end

  def update
    DB.execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.all
    rows = DB.execute("SELECT * FROM dogs;")
    rows.map { |row| Dog.new_from_db(row) }
  end

  def self.find_by_name(name)
    row = DB.execute("SELECT * FROM dogs WHERE name = ? LIMIT 1;", name).first
    Dog.new_from_db(row) if row
  end

  def self.find(id)
    row = DB.execute("SELECT * FROM dogs WHERE id = ? LIMIT 1;", id).first
    Dog.new_from_db(row) if row
  end

  private

  def self.DB
    @@db ||= SQLite3::Database.new(':memory:')
  end
end
