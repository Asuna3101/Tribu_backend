require 'sequel'
require 'bcrypt'

# Conexión a la base de datos usando el nombre correcto y la ruta completa
DB = Sequel.connect('sqlite://D:/PM/PM/backend/db/Tribu.db')

# Código para cifrar las contraseñas
usuarios = DB[:usuarios]

usuarios.each do |usuario|
  contrasenia_actual = usuario[:contrasenia]
  unless contrasenia_actual.start_with?("$2a$")
    contrasenia_cifrada = BCrypt::Password.create(contrasenia_actual)
    usuarios.where(id: usuario[:id]).update(contrasenia: contrasenia_cifrada)
    puts "Contraseña cifrada para el usuario con ID #{usuario[:id]}"
  end
end

puts "Todas las contraseñas han sido cifradas correctamente."
