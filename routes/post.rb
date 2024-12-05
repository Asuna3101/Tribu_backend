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
              Sequel[:posts][:fecha_subida_post].as(:fecha_subida)
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
