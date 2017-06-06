# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_record'

db_config = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

before { ActiveRecord::Base.verify_active_connections! if ActiveRecord::Base.respond_to?(:verify_active_connections!) }
after { ActiveRecord::Base.clear_active_connections! }

AUHTOR_PARAMS = [:name].freeze
BOOK_PARAMS = [:title, :author_id, :price]

class Author < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
end

class Book < ActiveRecord::Base
  belongs_to :author

  validates :title, uniqueness: true, presence: true

  def price
    cents / 100.0
  end

  def price=(value)
    value = value.to_f if value.is_a?(String)
    self.cents = (value * 100).to_i
  end

  def self.to_custom_json(scope = all)
    scope.map { |book| book.to_custom_json }.to_json
  end

  def to_custom_json
    {
      title: title,
      author: author.name,
      price: price
    }
  end
end

get '/' do
  json message: 'Welcome to the bookshop!'
end

get '/authors' do
  json Author.all
end

get '/authors/:id' do
  json Author.find(params[:id])
end

post '/authors' do
  author = Author.create(params.slice(*AUHTOR_PARAMS))
  if author.persisted?
    json message: 'Author created', status: 'ok'
  else
    json message: author.errors.full_messages, status: 'error'
  end
end

put '/authors/:id' do
  author = Author.find(params[:id])
  if author.update(params.slice(*AUHTOR_PARAMS))
    json message: 'Author updated', status: 'ok'
  else
    json message: author.errors.full_messages, status: 'error'
  end
end

delete '/authors/:id' do
  if Author.find(params[:id]).destroy
    json message: 'Author destroyed', status: 'ok'
  else
    json message: 'Author not destroyed', status: 'error'
  end
end

get '/books' do
  response.headers['Content-Type'] = 'application/json'
  Book.all.to_custom_json
end

get '/books/:id' do
  json Book.find(params[:id])
end

post '/books' do
  book = Book.create(params.slice(*BOOK_PARAMS))
  if book.persisted?
    json message: 'Book created', status: 'ok'
  else
    json message: book.errors.full_messages, status: 'error'
  end
end

put '/books/:id' do
  book = Book.find(params[:id])
  if book.update(params.slice(*BOOK_PARAMS))
    json message: 'Book updated', status: 'ok'
  else
    json message: book.errors.full_messages, status: 'error'
  end
end

delete '/books/:id' do
  if Book.find(params[:id]).destroy
    json message: 'Book destroyed', status: 'ok'
  else
    json message: 'Book not destroyed', status: 'error'
  end
end
