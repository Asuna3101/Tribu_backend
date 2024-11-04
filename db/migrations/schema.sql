CREATE TABLE tipo_materiales (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre	VARCHAR(12)
);

CREATE TABLE categorias (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre	VARCHAR(30)
);

CREATE TABLE usuarios (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  usuario	VARCHAR(40),
  contrasenia	VARCHAR(40)
);

CREATE TABLE cursos (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre	VARCHAR(40),
  codigo INTEGER,
  imagen VARCHAR(30),
  descripcion TEXT,
  categoria_id	INTEGER NOT NULL,
  FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE docentes (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombres	VARCHAR(40),
  apellidos	VARCHAR(40),
  codigo INTEGER,
  imagen VARCHAR(30),
  correo VARCHAR(30),
  usuario_id	INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE secciones (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  codigo	INTEGER,
  diploma	VARCHAR(30),
  fecha_inicio DATETIME,
  fecha_fin DATETIME,
  docente_id INTEGER NOT NULL,
  curso_id INTEGER NOT NULL,
  FOREIGN KEY (docente_id) REFERENCES docentes(id),
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

CREATE TABLE alumnos (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombres	VARCHAR(80),
  codigo INTEGER,
  imagen VARCHAR(30),
  correo VARCHAR(30),
  usuario_id	INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE materiales (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nombre	VARCHAR(40),
  descripcion	TEXT,
  momento DATETIME,
  url VARCHAR(50),
  seccion_id	INTEGER NOT NULL,
  tipo_material_id	INTEGER NOT NULL,
  FOREIGN KEY (seccion_id) REFERENCES secciones(id),
  FOREIGN KEY (tipo_material_id) REFERENCES tipo_materiales(id)
);

CREATE TABLE secciones_alumnos (
  id	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  nota INTEGER,
  seccion_id	INTEGER NOT NULL,
  alumno_id	INTEGER NOT NULL,
  FOREIGN KEY (seccion_id) REFERENCES secciones(id),
  FOREIGN KEY (alumno_id) REFERENCES alumnos(id)
);

CREATE VIEW vw_usuarios_logeados AS
  SELECT 
    U.id AS usuario_id, 
    U.usuario,
    A.nombres AS nombre,
    codigo,
    imagen,
    correo,
	A.id AS persona_id,
    'alumno' AS tipo 
	FROM usuarios U INNER JOIN alumnos A ON A.usuario_id = U.id
  UNION 
  SELECT 
    U.id AS usuario_id, 
    U.usuario,
    D.apellidos || ', ' || D.nombres AS nombre,
    codigo,
    imagen,
    correo,
	D.id AS persona_id,
    'docente' AS tipo 
	FROM usuarios U INNER JOIN docentes D ON D.usuario_id = U.id;