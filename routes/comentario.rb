# Obtener la cantidad de comentarios en un post
get '/post/:post_id/comments/count' do
    post_id = params[:post_id]
  
    begin
      # Contar la cantidad de comentarios en el post
      comment_count = Comentario.where(post_id: post_id).count
  
      status 200
      { count: comment_count }.to_json
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  
  # Obtener todos los comentarios de un post con el usuario que los hizo
  get '/post/:post_id/comments' do
    post_id = params[:post_id]
  
    begin
      # Obtener los comentarios y los nombres de los usuarios
      comentarios = Comentario.where(post_id: post_id)
                              .eager(:usuario) # Cargar la relación con Usuario
                              .all
                              .map do |comentario|
        {
          comentario: comentario.texto,
          fecha: comentario.fecha,
          usuario: comentario.usuario.nombre
        }
      end
  
      if comentarios.any?
        status 200
        comentarios.to_json
      else
        status 404
        { error: 'No hay comentarios para este post' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  
  # Comentar en un post
  post '/post/:post_id/comment' do
    post_id = params[:post_id]
    data = JSON.parse(request.body.read) rescue {}
    usuario_id = data['usuario_id']
    texto = data['texto']
  
    begin
      # Crear un nuevo comentario en el post
      comentario = Comentario.create(
        post_id: post_id,
        usuario_id: usuario_id,
        texto: texto,
        fecha: Time.now
      )
  
      status 201
      { message: 'Comentario agregado con éxito', comentario: comentario }.to_json
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  ############################################
  # Borrar un comentario
delete '/post/:post_id/comment/:comment_id' do
    post_id = params[:post_id]
    comment_id = params[:comment_id]
    data = JSON.parse(request.body.read) rescue {}
    usuario_id = data['usuario_id'] # ID del usuario que está intentando borrar el comentario
  
    begin
      # Encontrar el comentario
      comentario = Comentario[comment_id]
      post = Post[post_id]
  
      if comentario && post
        # Verificar si el usuario que intenta borrar es el autor del comentario o el autor del post
        if comentario.usuario_id == usuario_id || post.usuario_id == usuario_id
          comentario.destroy
          status 200
          { message: 'Comentario eliminado con éxito' }.to_json
        else
          status 403
          { error: 'No tienes permiso para eliminar este comentario' }.to_json
        end
      else
        status 404
        { error: 'Comentario o post no encontrado' }.to_json
      end
    rescue StandardError => e
      status 500
      { error: "Error en el servidor: #{e.message}" }.to_json
    end
  end
  #################################
  get '/posts/comentarios/:post_id' do
    post_id = params[:post_id].to_i # Obtiene el ID del post desde los parámetros
  
    begin
      # Query para obtener los comentarios y los usuarios asociados al post
      comentarios = DB[:comentarios]
        .join(:usuarios, id: :usuario_id)
        .join(:posts, id: Sequel[:comentarios][:post_id])
        .where(Sequel[:comentarios][:post_id] => post_id) # Filtrar por post_id
        .select(
          Sequel[:comentarios][:id].as(:comentario_id),
          Sequel[:comentarios][:texto].as(:comentario_texto),
          Sequel[:usuarios][:nombre].as(:usuario_nombre)
        )
        .all
  
      if comentarios.any?
        # Si hay comentarios, retornarlos en formato JSON
        status 200
        comentarios.to_json
      else
        # Si no hay comentarios para ese post, devolver un mensaje 404
        status 404
        { message: "No comments found for the post with ID #{post_id}." }.to_json
      end
    rescue StandardError => e
      # Manejar errores y devolver un mensaje de error 500
      status 500
      { error: "Server error: #{e.message}" }.to_json
    end
  end
  