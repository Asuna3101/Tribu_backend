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
