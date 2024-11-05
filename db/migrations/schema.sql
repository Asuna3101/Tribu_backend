CREATE TABLE carreras (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre VARCHAR(150)
);

CREATE TABLE niveles (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre VARCHAR(100)
);

CREATE TABLE usuarios (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  codigo VARCHAR(15) NOT NULL,
  correo VARCHAR(150) NOT NULL,
  nombre VARCHAR(200),
  celular VARCHAR(15),
  foto VARCHAR(200),
  contrasenia VARCHAR(150) NOT NULL,
  carrera_id INTEGER NOT NULL,
  FOREIGN KEY (carrera_id) REFERENCES carreras(id)
);

CREATE TABLE profesores (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre VARCHAR(200),
  correo VARCHAR(150),
  biografia VARCHAR(500)
);

CREATE TABLE cursos (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre VARCHAR(150),
  nivel_id INTEGER NOT NULL,
  FOREIGN KEY (nivel_id) REFERENCES niveles(id)
);

CREATE TABLE curso_profesor (
  curso_id INTEGER NOT NULL,
  profesor_id INTEGER NOT NULL,
  PRIMARY KEY (curso_id, profesor_id),
  FOREIGN KEY (curso_id) REFERENCES cursos(id),
  FOREIGN KEY (profesor_id) REFERENCES profesores(id)
);

CREATE TABLE posts (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  descripcion VARCHAR(500),
  fecha_subida_post DATE,
  usuario_id INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE comentarios (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  texto VARCHAR(500),
  fecha DATE,
  post_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE materiales (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre VARCHAR(200),
  tipo VARCHAR(200),
  fecha_subida DATE,
  enlace VARCHAR(250),
  post_id INTEGER NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE notificaciones (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  tipo_notificacion SMALLINT,
  fecha DATE,
  visto CHAR(1),
  usuario_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE reacciones (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  fecha DATE,
  post_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE secciones (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  codigo VARCHAR(15),
  profesor_id INTEGER NOT NULL,
  curso_id INTEGER NOT NULL,
  FOREIGN KEY (profesor_id) REFERENCES profesores(id),
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

CREATE TABLE seccion_usuario (
  seccion_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  PRIMARY KEY (seccion_id, usuario_id),
  FOREIGN KEY (seccion_id) REFERENCES secciones(id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE calificaciones (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  resenia VARCHAR(500),
  estrella INTEGER,
  fecha_subida DATE,
  usuario_id INTEGER NOT NULL,
  profesor_id INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (profesor_id) REFERENCES profesores(id)
);

CREATE TABLE post_curso (
  post_id INTEGER NOT NULL,
  curso_id INTEGER NOT NULL,
  PRIMARY KEY (post_id, curso_id),
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);