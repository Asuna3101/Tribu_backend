require 'json'

post '/usuario/validar' do
  # params (json)
  status = 500
  resp = ''
  body = request.body.read
  data = JSON.parse(body) 
  usuario = data['usuario']
  contrasenia = data['contrasenia']
  # db access
  begin
    # SELECT id FROM usuarios
    # WHERE usuario = '#{usuario}' AND contrasenia = '#{contrasenia}';
    record = Usuario.where(usuario: usuario, contrasenia: contrasenia).select(:id).first
    # result set
    usuario_id = nil
    member_id = nil
    data = ''
    message = ''
    if record then
      resp = UsuarioLogueado.where(usuario_id: record.id).first.to_json
      status = 200
    else
      status = 404
      resp = 'Usuario y/o contraseña no válidos'
    end
  rescue Sequel::DatabaseError => e
    status = 500
    resp = 'Error al acceder a la base de datos'
    puts e.message
  rescue StandardError => e
    status = 500
    resp = 'Ocurrió un error no esperado al validar el usuario'
    puts e.message
  end
  # response
  status status
  return resp
end

post '/usuario/cambiar-contrasenia' do
  # params
  status = 500
  resp = ''
  correo = params[:correo]
  # db access
  begin
    chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    new_password = (0...3).map { chars[rand(chars.length)] }.join
    query = <<-STRING
      UPDATE usuarios SET contrasenia = '#{new_password}' WHERE id = (
        SELECT usuario_id FROM vw_usuarios_logeados 
        WHERE correo = '#{correo}'
      );
    STRING
    puts query
    records = DB[query].update
    puts records
    if records > 0 then
      resp = 'Contraseña actualizada'
      status = 200
    else
      status = 404
      resp = 'Correo no registrado'
    end
  rescue Sequel::DatabaseError => e
    # resp[:message] = 'Error al acceder a la base de datos'
    # resp[:data] = e.message
    resp = e.message
  rescue StandardError => e
    # resp[:message] = 'Error al acceder a la base de datos'
    # resp[:data] = e.message
    resp = e.message
  end
  # response
  status status
  resp
end

post '/usuario/crear-usuario' do
  # INSERT INTO alumnos (nombres, codigo, imagen, correo) VALUES ('Pepe Valdivia', 20051191, 'alumnos/pp.png', '20051191@aloe.ulima.edu.pe');
  # INSERT INTO docentes (nombres, apellidos, codigo, imagen, correo) VALUES ('Chicle', 'Pikerton', 63733, 'alumnos/chicle.png', 'chicle@ulima.edu.pe');
  # params
  status = 500
  resp = ''
  correo = params[:correo]
  usuario = params[:usuario]
  contrasenia = params[:contrasenia]
  # db access
  begin
    usuarios = Usuario.where(usuario: usuario).count
    if usuarios == 0 then
      docente = Docente.where(correo: correo).first
      if docente then
        if docente.usuario_id == nil then
          usuario = Usuario.new(usuario: usuario, contrasenia: contrasenia)
          usuario.save
          docente.update(usuario_id: usuario.id)
          resp = 'Se le ha enviado un correo con su link de activación'
          status = 200
        else
          resp = 'Docente ya tiene registrado un usuario'
          status = 500
        end
      else
        alumno = Alumno.where(correo: correo).first
        puts alumno.to_json
        if alumno then
          puts 'iffffffffffffffffffffffffff'
          if alumno.usuario_id == nil then
            usuario = Usuario.new(usuario: usuario, contrasenia: contrasenia)
            usuario.save
            alumno.update(usuario_id: usuario.id)
            resp = 'Se le ha enviado un correo con su link de activación'
            status = 200
          else
            puts 'elseseeeeeeeeee'
            resp = 'Alumno ya tiene registrado un usuario'
            status = 500
          end
        else
          resp = 'Correo no registrado'
          status = 404
        end
      end
    else
      status = 500
      resp = 'Usuario ya en uso'
    end
  rescue Sequel::DatabaseError => e
    # resp[:message] = 'Error al acceder a la base de datos'
    # resp[:data] = e.message
    resp = e.message
  rescue StandardError => e
    # resp[:message] = 'Error al acceder a la base de datos'
    # resp[:data] = e.message
    resp = e.message
  end
  # response
  status status
  resp
end