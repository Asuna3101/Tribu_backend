require 'json'
require 'jwt'
require 'net/smtp'

REFRESH_TOKEN = ENV['REFRESH_TOKEN'] || 'default_refresh_token'
SECRET_KEY = ENV['SECRET_KEY'] || 'default_secret_key'

# Endpoint para login usando código y contraseña
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
  
  if auth_token.nil? || !auth_token.start_with?("Bearer ")
    status 401
    return { error: 'Token no proporcionado o formato inválido' }.to_json
  end

  token = auth_token.split(' ').last

  begin
    decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    user_id = decoded_token[0]['id']
    
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

  if nombre.nil? || codigo.nil? || correo.nil? || contrasenia.nil?
    status 400
    return { error: 'Debe llenar todos los campos requeridos' }.to_json
  end

  existing_user = Usuario.find(codigo: codigo)
  if existing_user
    status 400
    return { error: 'Usuario ya existe con ese código' }.to_json
  end

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
end

# Endpoint para cambiar contraseña autenticado
put '/change-password' do
  auth_token = request.env['HTTP_AUTHORIZATION']
  return status 401, { error: 'Token no proporcionado' }.to_json unless auth_token
  token = auth_token.split(' ').last
  data = JSON.parse(request.body.read) rescue {}
  new_contrasenia = data['newContrasenia']
  repetir_contrasenia = data['repetirContrasenia']

  # Verifica que ambas contraseñas nuevas coincidan
  unless new_contrasenia == repetir_contrasenia
    status 400
    return { error: 'Las contraseñas no coinciden' }.to_json
  end

  begin
    # Decodifica el token para obtener el ID del usuario
    decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    user_id = decoded_token[0]['id']
    user = Usuario.find(id: user_id)
    
    if user
      # Actualiza la contraseña del usuario
      user.update(contrasenia: new_contrasenia)
      status 200
      { message: 'Contraseña actualizada con éxito' }.to_json
    else
      status 404
      { error: 'Usuario no encontrado' }.to_json
    end
  rescue JWT::DecodeError
    status 401
    { error: 'Token no válido' }.to_json
  end
end




# Función para enviar el correo con la contraseña temporal
def send_temporary_password(email, temporary_password)
  message = <<~MESSAGE_END
    From: Soporte <andreaximena2004@gmail.com>
    To: Usuario <#{email}>
    Subject: Recuperación de Contraseña

    Hola,

    Has solicitado recuperar tu contraseña. Usa la siguiente contraseña temporal para acceder a tu cuenta:

    Contraseña temporal: #{temporary_password}

    Te recomendamos cambiar esta contraseña después de iniciar sesión.

    Saludos,
    El equipo de soporte de Tribu
  MESSAGE_END

  # Configuración para el servidor SMTP de Gmail
  smtp_server = 'smtp.gmail.com'
  smtp_port = 587
  username = 'andreaximena2004@gmail.com'       # Reemplaza con tu dirección de correo de Gmail
  password = 'igqh nuyp rfrz kckk'        # Reemplaza con tu contraseña de aplicación de Gmail

  # Enviar el correo usando Gmail
  Net::SMTP.start(smtp_server, smtp_port, 'gmail.com', username, password, :login) do |smtp|
    smtp.send_message message, username, email
  end
end

# Endpoint para cambiar contraseña (olvidada) sin autenticación
post '/usuario/contrasenia-olvidada' do
  data = JSON.parse(request.body.read) rescue {}
  correo = data['correo']  # Cambia para extraer el correo desde JSON
  
  # Generar una contraseña temporal de 8 caracteres
  new_password = Array.new(8) { [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten.sample }.join

  user = Usuario.find(correo: correo)

  if user
    user.update(contrasenia: new_password)
    send_temporary_password(correo, new_password)  # Llamada a la función de envío de correo
    status 200
    { message: 'Contraseña temporal generada y enviada por correo.' }.to_json
  else
    status 404
    { error: 'Correo no registrado' }.to_json
  end
rescue StandardError => e
  status 500
  { error: "Error en el servidor: #{e.message}" }.to_json
end





