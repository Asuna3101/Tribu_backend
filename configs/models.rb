require_relative 'database'

class Usuario < Sequel::Model(DB[:usuarios])
end

class Carrera < Sequel::Model(DB[:carreras])
end

class UsuarioLogueado < Sequel::Model(DB[:usuarios])
end

class Profesor < Sequel::Model(DB[:profesores])
end

class Calificacion < Sequel::Model(DB[:calificaciones])
end

class Comentario < Sequel::Model(DB[:comentarios])
end

'''
class Level < Sequel::Model(DB[:levels])
end

class Exercise < Sequel::Model(DB[:exercises])
end

class BodyPart < Sequel::Model(DB[:body_parts])
end
'''