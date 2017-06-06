# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[5.0]
  def self.up
    create_table :authors do |table|
      table.string :name, null: false, default: ''
    end

    create_table :books do |table|
      table.string :title, null: false, default: ''
      table.references :author, null: false
      table.integer :cents, null: false, default: 0
    end
  end

  def self.down
    drop_table :books
  end
end
