require_relative 'database'

# Modelo para la tabla de usuarios
class Usuario < Sequel::Model(DB[:usuarios])
  many_to_one :carrera
  one_to_many :posts
  one_to_many :notificaciones
  one_to_many :reacciones
  one_to_many :comentarios
  one_to_many :calificaciones
  many_to_many :secciones, join_table: :seccion_usuario
end

# Modelo para la tabla de carreras
class Carrera < Sequel::Model(DB[:carreras])
  one_to_many :usuarios
end

# Modelo para la tabla de profesores
class Profesor < Sequel::Model(DB[:profesores])
  one_to_many :calificaciones
  many_to_many :cursos, join_table: :curso_profesor
end

# Modelo para la tabla de calificaciones
class Calificacion < Sequel::Model(DB[:calificaciones])
  many_to_one :usuario
  many_to_one :profesor
end

# Modelo para la tabla de comentarios
class Comentario < Sequel::Model(DB[:comentarios])
  many_to_one :usuario
  many_to_one :post
end

# Modelo para la tabla de cursos
class Curso < Sequel::Model(DB[:cursos])
  many_to_one :nivel
  one_to_many :secciones
  many_to_many :posts, join_table: :post_curso
  many_to_many :profesores, join_table: :curso_profesor
end

# Modelo para la tabla de niveles
class Nivel < Sequel::Model(DB[:niveles])
  one_to_many :cursos
end

# Modelo para la tabla de posts
class Post < Sequel::Model(DB[:posts])
  many_to_one :usuario
  one_to_many :comentarios
  one_to_many :materiales
  many_to_many :cursos, join_table: :post_curso
end

# Modelo para la tabla de notificaciones
class Notificacion < Sequel::Model(DB[:notificaciones])
  many_to_one :usuario
  many_to_one :post
end

# Modelo para la tabla de reacciones
class Reaccion < Sequel::Model(DB[:reacciones])
  many_to_one :usuario
  many_to_one :post
end

# Modelo para la tabla de materiales
class Material < Sequel::Model(DB[:materiales])
  many_to_one :post
end

# Modelo para la tabla de secciones
class Seccion < Sequel::Model(DB[:secciones])
  many_to_one :curso
  many_to_one :profesor
  many_to_many :usuarios, join_table: :seccion_usuario
end

# Modelo para la tabla intermedia Post_Curso
class PostCurso < Sequel::Model(DB[:post_curso])
end

# Modelo para la tabla intermedia Seccion_Usuario
class SeccionUsuario < Sequel::Model(DB[:seccion_usuario])
end

# Modelo para la tabla intermedia Curso_Profesor
class CursoProfesor < Sequel::Model(DB[:curso_profesor])
end
