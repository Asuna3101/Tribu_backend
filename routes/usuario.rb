require 'json'
require 'jwt'
require 'bcrypt'
require 'net/smtp'


REFRESH_TOKEN = ENV['REFRESH_TOKEN'] || 'default_refresh_token'

# Endpoint para login usando código y contraseña

SECRET_KEY = ENV['SECRET_KEY'] || 'default_secret_key'

post '/login' do
  data = JSON.parse(request.body.read)
  codigo = data['codigo']
  contrasenia = data['contrasenia']
  
  if codigo.nil? || contrasenia.nil?
    status 400
    return { error: 'Debe haber un Código y una Contraseña' }.to_json
  end
  
  begin
    # Encuentra al usuario en la base de datos usando el código
    user = Usuario.find(codigo: codigo)
    
    # Verifica si el usuario existe y si la contraseña coincide
    if user && user.contrasenia == contrasenia
      # Genera el token JWT
      token = JWT.encode({ id: user.id, codigo: user.codigo }, SECRET_KEY, 'HS256')
      status 200
      { token: token }.to_json
    else
      # Respuesta si las credenciales son incorrectas
      status 401
      { error: 'Código o contraseña incorrectos' }.to_json
    end
  rescue StandardError => e
    # Manejo de errores
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


# Endpoint para obtener usuario autenticado



get '/usuario' do
  auth_token = request.env['HTTP_AUTHORIZATION']
  
  # Verifica que el token esté presente en el encabezado
  if auth_token.nil? || !auth_token.start_with?("Bearer ")
    status 401
    return { error: 'Token no proporcionado o formato inválido' }.to_json
  end
  
  # Extrae el token eliminando la parte "Bearer "
  token = auth_token.split(' ').last
  
  begin
    # Decodifica el token
    decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    user_id = decoded_token[0]['id']
    
    # Busca al usuario en la base de datos
    user = Usuario.find(id: user_id)
    
    if user
      status 200
      return user.to_json
    else
      status 404
      return { error: 'Usuario no encontrado' }.to_json
    end
  rescue JWT::DecodeError
    status 401
    { error: 'Token no válido' }.to_json
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


# Endpoint para crear usuario
post '/usuarios' do
  data = JSON.parse(request.body.read)
  nombre = data['nombre']
  codigo = data['codigo']
  correo = data['correo']
  celular = data['celular']
  foto = data['foto']
  contrasenia = data['contrasenia']
  carrera_id = data['carrera_id']
  
  # Validación de campos requeridos
  if nombre.nil? || codigo.nil? || correo.nil? || contrasenia.nil?
    status 400
    return { error: 'Debe llenar todos los campos requeridos' }.to_json
  end

  # Verificación de usuario existente basado en el código
  existing_user = Usuario.find(codigo: codigo)
  if existing_user
    status 400
    return { error: 'Usuario ya existe con ese código' }.to_json
  end

  # Creación del nuevo usuario
  new_user = Usuario.new(
    nombre: nombre,
    codigo: codigo,
    correo: correo,
    celular: celular,
    foto: foto,
    contrasenia: contrasenia,
    carrera_id: carrera_id
  )

  if new_user.save
    status 201
    { message: 'Usuario creado con éxito' }.to_json
  else
    status 500
    { error: 'Error al crear el usuario' }.to_json
  end
rescue JSON::ParserError
  status 400
  { error: 'Formato de JSON inválido' }.to_json
rescue StandardError => e
  status 500
  { error: "Error en el servidor: #{e.message}" }.to_json
end


# Endpoint para cambiar contraseña autenticado
put '/change-password' do
  auth_token = request.env['HTTP_AUTHORIZATION']
  return status 401, { error: 'Token no proporcionado' }.to_json unless auth_token
  token = auth_token.split(' ').last
  data = JSON.parse(request.body.read) rescue {}
  old_contrasenia = data['oldContrasenia']
  new_contrasenia = data['newContrasenia']
  
  begin
    decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    user_id = decoded_token[0]['id']
    user = Usuario.find(id: user_id)
    
    if user && BCrypt::Password.new(user.contrasenia) == old_contrasenia
      hashed_password = BCrypt::Password.create(new_contrasenia)
      user.update(contrasenia: hashed_password)
      status 200
      { message: 'Contraseña actualizada con éxito' }.to_json
    else
      status 400
      { error: 'Contraseña antigua incorrecta' }.to_json
    end
  rescue JWT::DecodeError
    status 401
    { error: 'Token no válido' }.to_json
  end
end

# Endpoint para cambiar contraseña (olvidada) sin autenticación
post '/usuario/cambiar-contrasenia' do
  status = 500
  resp = ''
  correo = params[:correo]

  begin
    # Generar una nueva contraseña temporal
    chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    new_password = (0...8).map { chars[rand(chars.length)] }.join  # Contraseña temporal de 8 caracteres

    # Actualizar la contraseña en la base de datos
    query = <<-SQL
      UPDATE usuarios SET contrasenia = '#{BCrypt::Password.create(new_password)}' WHERE correo = '#{correo}';
    SQL

    records = DB[query].update  # Ejecutar la consulta de actualización

    if records > 0
      resp = "Contraseña temporal generada: #{new_password}"  # Muestra la contraseña temporal en la respuesta
      status = 200
    else
      status = 404
      resp = 'Correo no registrado'
    end

  rescue Sequel::DatabaseError => e
    resp = "Error al acceder a la base de datos: #{e.message}"
  rescue StandardError => e
    resp = "Ocurrió un error: #{e.message}"
  end

  # Enviar la respuesta con el estado y el mensaje
  status status
  resp
end

# Endpoint para resetear contraseña con token de recuperación
put '/reset-password' do
  data = JSON.parse(request.body.read) rescue {}
  token = data['token']
  new_contrasenia = data['newContrasenia']
  
  begin
    decoded_token = JWT.decode(token, REFRESH_TOKEN, true, { algorithm: 'HS256' })
    user_id = decoded_token[0]['id']
    user = Usuario.find(id: user_id, recovery_password: token)
    
    if user
      hashed_password = BCrypt::Password.create(new_contrasenia)
      user.update(contrasenia: hashed_password, recovery_password: nil)
      status 200
      { message: 'Contraseña restablecida con éxito' }.to_json
    else
      status 404
      { error: 'Token no válido o usuario no encontrado' }.to_json
    end
  rescue JWT::DecodeError
    status 401
    { error: 'Token no válido' }.to_json
  end
end
