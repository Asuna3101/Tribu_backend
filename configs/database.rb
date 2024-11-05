require 'sequel'

DB = Sequel.sqlite('db/Tribu.db')
Sequel::Model.plugin :json_serializer