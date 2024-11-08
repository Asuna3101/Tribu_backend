-- ============================================
-- CALIFICACIÓN
-- ============================================

-- Obtener todas las calificaciones de un profesor
SELECT calificaciones.*, usuarios.nombre AS usuario_nombre
FROM calificaciones
JOIN usuarios ON calificaciones.usuario_id = usuarios.id
WHERE calificaciones.profesor_id = {profesor_id};

-- Obtener el promedio de calificaciones de un profesor
SELECT AVG(estrella) AS promedio_calificaciones
FROM calificaciones
WHERE profesor_id = {profesor_id};

-- Registrar una calificación para un profesor
INSERT INTO calificaciones (resenia, estrella, fecha_subida, usuario_id, profesor_id)
VALUES ('{resenia}', {estrella}, CURRENT_TIMESTAMP, {usuario_id}, {profesor_id});


-- ============================================
-- CARRERA
-- ============================================

-- Listar todas las carreras
SELECT * FROM carreras;


-- ============================================
-- COMENTARIO
-- ============================================

-- Obtener la cantidad de comentarios en un post
SELECT COUNT(*) AS cantidad_comentarios
FROM comentarios
WHERE post_id = {post_id};

-- Obtener todos los comentarios de un post con el nombre del usuario que lo hizo
SELECT comentarios.*, usuarios.nombre AS usuario_nombre
FROM comentarios
JOIN usuarios ON comentarios.usuario_id = usuarios.id
WHERE comentarios.post_id = {post_id};

-- Comentar en un post
INSERT INTO comentarios (texto, fecha, post_id, usuario_id)
VALUES ('{texto}', CURRENT_TIMESTAMP, {post_id}, {usuario_id});

-- Borrar un comentario en un post (solo el usuario que lo publicó o el creador del post puede borrarlo)
DELETE FROM comentarios
WHERE id = {comentario_id} AND (usuario_id = {usuario_id} OR post_id = {post_id});


-- ============================================
-- MATERIAL
-- ============================================

-- Listar todos los materiales
SELECT nombre FROM materiales;

-- Obtener materiales relacionados a un curso específico
SELECT materiales.nombre
FROM materiales
JOIN posts ON materiales.post_id = posts.id
JOIN post_curso ON posts.id = post_curso.post_id
JOIN cursos ON post_curso.curso_id = cursos.id
WHERE cursos.nombre LIKE '%{nombre_curso}%';


-- ============================================
-- POST
-- ============================================

-- Listar todos los posts con detalles de usuario, carrera, comentarios y reacciones
SELECT posts.*, usuarios.nombre AS usuario_nombre, carreras.nombre AS carrera_nombre,
       COUNT(DISTINCT comentarios.id) AS cantidad_comentarios, COUNT(DISTINCT reacciones.id) AS cantidad_reacciones
FROM posts
JOIN usuarios ON posts.usuario_id = usuarios.id
JOIN carreras ON usuarios.carrera_id = carreras.id
LEFT JOIN comentarios ON comentarios.post_id = posts.id
LEFT JOIN reacciones ON reacciones.post_id = posts.id
GROUP BY posts.id, usuarios.nombre, carreras.nombre
ORDER BY posts.fecha_subida_post DESC;

-- Publicar un post
INSERT INTO posts (descripcion, fecha_subida_post, usuario_id)
VALUES ('{descripcion}', CURRENT_TIMESTAMP, {usuario_id});


-- ============================================
-- PROFESOR
-- ============================================

-- Obtener información de un profesor
SELECT * FROM profesores WHERE id = {profesor_id};


-- ============================================
-- REACCIÓN
-- ============================================

-- Obtener todas las reacciones a un post
SELECT reacciones.*, usuarios.nombre AS usuario_nombre
FROM reacciones
JOIN usuarios ON reacciones.usuario_id = usuarios.id
WHERE reacciones.post_id = {post_id};

-- Obtener todas las reacciones de un usuario
SELECT reacciones.*, posts.descripcion AS post_descripcion
FROM reacciones
JOIN posts ON reacciones.post_id = posts.id
WHERE reacciones.usuario_id = {usuario_id};

-- Registrar una reacción en un post
INSERT INTO reacciones (fecha, post_id, usuario_id)
VALUES (CURRENT_TIMESTAMP, {post_id}, {usuario_id});


-- ============================================
-- USUARIO
-- ============================================

-- Registrar un nuevo usuario
INSERT INTO usuarios (codigo, nombre, correo, celular, foto, contrasenia, carrera_id)
VALUES ('{codigo}', '{nombre}', '{correo}', '{celular}', '{foto}', '{contrasenia}', {carrera_id});



