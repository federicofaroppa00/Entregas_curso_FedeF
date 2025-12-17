
-- CORRECCIONES EN TABLAS
-- =========================
ALTER TABLE ventas MODIFY COLUMN id_personal INT NULL;

-- =========================
-- VISTAS
-- =========================
CREATE VIEW vw_ventas_detalladas AS
SELECT v.id_venta, v.fecha_venta, c.nombre AS cliente, p.nombre_producto AS producto,
dv.cantidad, dv.precio_unitario
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN detalle_venta dv ON v.id_venta = dv.id_venta
JOIN productos p ON dv.id_producto = p.id_producto;

CREATE VIEW vw_stock_actual AS
SELECT p.nombre_producto AS producto, i.cantidad_disponible
FROM inventario i
JOIN productos p ON i.id_producto = p.id_producto;

CREATE VIEW vw_ventas_producto_fecha AS
SELECT p.id_producto, p.nombre_producto, DATE(v.fecha_venta) AS fecha,
SUM(dv.cantidad) AS cantidad_vendida, SUM(dv.precio_unitario * dv.cantidad) AS total_vendido
FROM productos p
JOIN detalle_venta dv ON p.id_producto = dv.id_producto
JOIN ventas v ON dv.id_venta = v.id_venta
GROUP BY p.id_producto, p.nombre_producto, DATE(v.fecha_venta);

-- =========================
-- FUNCIONES
-- =========================
DELIMITER //
CREATE FUNCTION fn_total_cliente(p_cliente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(dv.precio_unitario * dv.cantidad)
    INTO total
    FROM ventas v
    JOIN detalle_venta dv ON v.id_venta = dv.id_venta
    WHERE v.id_cliente = p_cliente;
    RETURN IFNULL(total, 0);
END//

CREATE FUNCTION fn_total_producto_dia(p_producto INT, p_fecha DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT SUM(dv.cantidad)
    INTO total
    FROM detalle_venta dv
    JOIN ventas v ON dv.id_venta = v.id_venta
    WHERE dv.id_producto = p_producto AND DATE(v.fecha_venta) = p_fecha;
    RETURN IFNULL(total, 0);
END//

CREATE FUNCTION fn_horas_trabajadas(p_id INT, p_fecha DATE)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_horas DECIMAL(5,2);
    SELECT SUM(TIMESTAMPDIFF(MINUTE, hora_entrada, hora_salida)/60)
    INTO total_horas
    FROM asistencia
    WHERE id_personal = p_id AND fecha = p_fecha AND hora_salida IS NOT NULL;
    RETURN IFNULL(total_horas, 0);
END//

-- =========================
-- STORED PROCEDURES
-- =========================
CREATE PROCEDURE sp_actualizar_precio_producto(IN p_producto INT, IN p_precio DECIMAL(10,2))
BEGIN
    UPDATE productos SET precio = p_precio WHERE id_producto = p_producto;
END//

CREATE PROCEDURE sp_productos_stock_bajo(IN p_minimo INT)
BEGIN
    SELECT p.nombre_producto, i.cantidad_disponible
    FROM inventario i
    JOIN productos p ON i.id_producto = p.id_producto
    WHERE i.cantidad_disponible <= p_minimo;
END//

CREATE PROCEDURE sp_ranking_productos_mes(IN p_anio INT, IN p_mes INT)
BEGIN
    SELECT p.nombre_producto, SUM(dv.cantidad) AS total_unidades,
           SUM(dv.precio_unitario * dv.cantidad) AS total_monto
    FROM detalle_venta dv
    JOIN ventas v ON dv.id_venta = v.id_venta
    JOIN productos p ON dv.id_producto = p.id_producto
    WHERE YEAR(v.fecha_venta) = p_anio AND MONTH(v.fecha_venta) = p_mes
    GROUP BY p.id_producto
    ORDER BY total_unidades DESC
    LIMIT 10;
END//

-- =========================
-- TRIGGERS
-- =========================
CREATE TRIGGER trg_descontar_stock_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    UPDATE inventario
    SET cantidad_disponible = cantidad_disponible - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END//

CREATE TRIGGER trg_completar_hora_salida
BEFORE UPDATE ON asistencia
FOR EACH ROW
BEGIN
    IF NEW.hora_salida IS NULL THEN
        SET NEW.hora_salida = '20:00:00';
    END IF;
END//

CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    SELECT cantidad_disponible INTO v_stock FROM inventario WHERE id_producto = NEW.id_producto;
    IF v_stock < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
END//
DELIMITER ;

-- =========================
-- INSERCIONES DE DATOS 
-- =========================
INSERT INTO clientes (nombre, apellido, email, telefono, direccion) VALUES
('Juan', 'Pérez', 'juan.perez@mail.com', '099123456', 'Av. Libertador 123'),
('María', 'Gómez', 'maria.gomez@mail.com', '098654321', 'Calle 18 de Julio 456'),
('Carlos', 'Fernández', 'carlos.fernandez@mail.com', '097111222', 'Bvar. Artigas 789'),
('Lucía', 'Rodríguez', 'lucia.rodriguez@mail.com', '096333444', 'Av. Italia 321'),
('Pedro', 'Martínez', 'pedro.martinez@mail.com', '095555666', 'Camino Maldonado 654');

INSERT INTO personal (nombre, apellido, cargo, email, telefono, fecha_ingreso) VALUES
('Ana', 'Suárez', 'Vendedora', 'ana.suarez@mail.com', '099888777', '2022-01-10'),
('Luis', 'Torres', 'Gerente', 'luis.torres@mail.com', '098999888', '2021-03-15'),
('Sofía', 'López', 'Administrativa', 'sofia.lopez@mail.com', '097777666', '2023-06-01');

INSERT INTO productos (nombre_producto, material, precio, tipo) VALUES
('Anillo Oro 18k', 'Oro', 1500.00, 'Anillo'),
('Cadena Plata Italiana', 'Plata', 800.00, 'Cadena'),
('Pulsera Acero', 'Acero', 300.00, 'Pulsera'),
('Aros Diamante', 'Oro', 2500.00, 'Aro'),
('Reloj Clásico', 'Acero', 1200.00, 'Reloj');

INSERT INTO inventario (id_producto, cantidad_disponible, ultima_actualizacion) VALUES
(1, 10, CURDATE()), (2, 15, CURDATE()), (3, 8, CURDATE()), (4, 5, CURDATE()), (5, 12, CURDATE());

INSERT INTO proveedores (nombre_proveedor, telefono, email) VALUES
('Joyas SA', '29001234', 'contacto@joyassa.com'),
('Distribuidora Oro', '29005678', 'ventas@distribuidoraoro.com');

INSERT INTO compras (fecha_compra, id_proveedor, total) VALUES
('2024-11-10', 1, 5000.00),
('2024-11-15', 2, 3000.00);

INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 5, 1400.00),
(1, 2, 10, 750.00),
(2, 4, 3, 2400.00);

INSERT INTO ventas (fecha_venta, id_cliente, id_personal, total) VALUES
('2024-12-01', 1, 1, 2300.00),
('2024-12-02', 2, 2, 1500.00),
('2024-12-03', 3, NULL, 800.00);

INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 1500.00),
(1, 2, 1, 800.00),
(2, 5, 1, 1200.00),
(3, 2, 1, 800.00);

INSERT INTO asistencia (id_personal, fecha, hora_entrada, hora_salida, estado) VALUES
(1, '2024-12-01', '09:00:00', '18:00:00', 'Presente'),
(2, '2024-12-01', '09:30:00', '18:30:00', 'Presente');
