get '/posts/lista' do
  begin
    # Consulta para obtener los datos con JOIN entre las tablas
    posts = DB[:posts]
            .join(:usuarios, id: :usuario_id)
            .join(:carreras, id: Sequel[:usuarios][:carrera_id])
            .join(:materiales, post_id: Sequel[:posts][:id])
            .select(
              Sequel[:usuarios][:nombre].as(:nombre_usuario),
              Sequel[:usuarios][:foto].as(:foto_usuario), # Ajustado el alias aquí
              Sequel[:carreras][:nombre].as(:carrera),
              Sequel[:posts][:descripcion].as(:descripcion_post),
              Sequel[:materiales][:enlace].as(:enlace_material),
              Sequel[:posts][:fecha_subida_post].as(:fecha_subida),
              Sequel[:posts][:id].as(:post_id),
            
            )
            .order(Sequel.desc(:fecha_subida_post))
            .all

    if posts.any?
      # Devolver los datos en formato JSON
      status 200
      posts.to_json
    else
      # Si no hay publicaciones
      status 404
      { message: 'No hay publicaciones registradas.' }.to_json
    end
  rescue StandardError => e
    # Manejo de errores
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

get '/posts/usuario/:id' do
  usuario_id = params[:id].to_i # Get the user ID from the parameters

  begin
    # Query to get posts associated with the specific user
    posts = DB[:posts]
            .join(:usuarios, id: :usuario_id)
            .join(:carreras, id: Sequel[:usuarios][:carrera_id])
            .join(:materiales, post_id: Sequel[:posts][:id])
            .where(Sequel[:posts][:usuario_id] => usuario_id) # Filter by usuario_id
            .select(
              Sequel[:usuarios][:nombre].as(:nombre_usuario),
              Sequel[:usuarios][:foto].as(:foto_usuario),
              Sequel[:carreras][:nombre].as(:carrera),
              Sequel[:posts][:descripcion].as(:descripcion_post),
              Sequel[:materiales][:enlace].as(:enlace_material),
              Sequel[:posts][:fecha_subida_post].as(:fecha_subida),
              Sequel[:posts][:id].as(:post_id),
            )
            .order(Sequel.desc(:fecha_subida_post))
            .all

    if posts.any?
      # Return data in JSON format
      status 200
      posts.to_json
    else
      # Return 404 if no posts exist for the user
      status 404
      { message: "No posts registered for the user with ID #{usuario_id}." }.to_json
    end
  rescue StandardError => e
    # Handle errors
    status 500
    { error: "Server error: #{e.message}" }.to_json
  end
end
######################################################
post '/posts/crear' do
  begin
    # Obtener parámetros de la solicitud
    descripcion = params[:descripcion]
    archivo = params[:archivo] # Archivo subido

    # Validar que los parámetros sean correctos
    if descripcion.nil? || archivo.nil?
      status 400
      return { error: 'La descripción y el archivo son obligatorios.' }.to_json
    end

    # Guardar el archivo en una carpeta local (por ejemplo, 'uploads')
    nombre_archivo = archivo[:filename] # Nombre original del archivo
    ruta_archivo = "./uploads/#{nombre_archivo}" # Ruta de almacenamiento local

    # Crear carpeta 'uploads' si no existe
    Dir.mkdir('./uploads') unless Dir.exist?('./uploads')

    # Escribir el archivo en el sistema de archivos
    File.open(ruta_archivo, 'wb') do |f|
      f.write(archivo[:tempfile].read)
    end

    # Obtener el tipo de archivo (extensión)
    tipo_archivo = File.extname(nombre_archivo).delete('.')

    # Insertar el post en la tabla `posts`
    post_id = DB[:posts].insert(
      descripcion: descripcion,
      fecha_subida_post: Sequel::CURRENT_TIMESTAMP, # Fecha automática
      usuario_id: 1 # Cambia esto por el usuario autenticado (puede venir de la sesión)
    )

    # Insertar el material asociado en la tabla `materiales`
    DB[:materiales].insert(
      nombre: File.basename(nombre_archivo, ".*"), # Nombre del archivo sin la extensión
      tipo: tipo_archivo,
      fecha_subida: Sequel::CURRENT_TIMESTAMP, # Fecha automática
      enlace: ruta_archivo, # Ruta local del archivo
      post_id: post_id # Relación con el post
    )

    # Respuesta exitosa
    status 201
    { message: 'Post creado exitosamente.', post_id: post_id }.to_json

  rescue StandardError => e
    # Manejo de errores
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end
