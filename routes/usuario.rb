require 'json'

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
      # Enviar respuesta exitosa con los datos del usuario
      status 200
      { message: 'Inicio de sesión exitoso', usuario: user }.to_json
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

# Endpoint para obtener información del usuario sin autenticación (usando código)
get '/usuario/:codigo' do
  codigo = params['codigo']

  begin
    # Encuentra al usuario usando el código
    user = Usuario.find(codigo: codigo)

    if user
      status 200
      return user.to_json
    else
      status 404
      { error: 'Usuario no encontrado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint para buscar un usuario por correo
get '/usuario/correo/:correo' do
  correo = params['correo']

  begin
    # Encuentra al usuario usando el correo
    user = Usuario.find(correo: correo)

    if user
      status 200
      return user.to_json
    else
      status 404
      { error: 'Usuario no encontrado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint para crear un nuevo usuario
post '/usuarios' do
  data = JSON.parse(request.body.read)
  nombre = data['nombre']
  codigo = data['codigo']
  correo = data['correo']
  contrasenia = data['contrasenia']
  celular = data['celular']
  foto = data['foto']
  carrera_id = data['carrera_id']

  if nombre.nil? || codigo.nil? || correo.nil? || contrasenia.nil? || carrera_id.nil?
    status 400
    return { error: 'Debe llenar todos los campos requeridos' }.to_json
  end

  # Comprobamos si ya existe un usuario con el código proporcionado
  existing_user = Usuario.find(codigo: codigo)
  if existing_user
    status 400
    return { error: 'Usuario ya existe con ese código' }.to_json
  end

  # Crear un nuevo usuario con los datos adicionales
  new_user = Usuario.new(
    nombre: nombre,
    codigo: codigo,
    correo: correo,
    contrasenia: contrasenia,
    celular: celular,   # Campo celular
    foto: foto,         # Campo foto
    carrera_id: carrera_id  # Campo carrera_id
  )

  if new_user.save
    status 201
    { message: 'Usuario creado con éxito' }.to_json
  else
    status 500
    { error: 'Error al crear el usuario' }.to_json
  end
end


# Endpoint para actualizar la contraseña de un usuario
put '/usuarios/:codigo/contrasenia' do
  # Obtener el código y la nueva contraseña desde los parámetros de la URL y el cuerpo
  codigo = params['codigo']
  data = JSON.parse(request.body.read)
  nueva_contrasenia = data['nueva_contrasenia']

  # Validaciones básicas
  if nueva_contrasenia.nil? || nueva_contrasenia.empty?
    status 400
    return { error: 'La nueva contraseña no puede estar vacía' }.to_json
  end

  begin
    # Buscar el usuario por el código
    user = Usuario.find(codigo: codigo)

    # Si el usuario no existe
    if user.nil?
      status 404
      return { error: 'Usuario no encontrado' }.to_json
    end

    # Actualizar la contraseña en la base de datos
    user.update(contrasenia: nueva_contrasenia)

    # Respuesta exitosa
    status 200
    { message: 'Contraseña actualizada correctamente' }.to_json
  rescue StandardError => e
    # Manejo de errores
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end
