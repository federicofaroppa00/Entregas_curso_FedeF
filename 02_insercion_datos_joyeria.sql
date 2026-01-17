
-- Script 02: Inserción de datos - Joyería
USE joyeria_db;
INSERT INTO categorias (nombre) VALUES ('Anillo'), ('Cadena'), ('Pulsera'), ('Aro'), ('Reloj');
INSERT INTO marcas (nombre) VALUES ('Genérica'), ('OroFino'), ('Plata Italiana'), ('AceroMax');
INSERT INTO metodos_pago (nombre) VALUES ('Efectivo'), ('Tarjeta Crédito'), ('Tarjeta Débito'), ('Transferencia');
INSERT INTO clientes (nombre, apellido, email, telefono, direccion) VALUES ('Juan', 'Pérez', 'juan.perez@mail.com', '099123456', 'Av. Libertador 123'), ('María', 'Gómez', 'maria.gomez@mail.com', '098654321', 'Calle 18 de Julio 456'), ('Carlos', 'Fernández', 'carlos.fernandez@mail.com', '097111222', 'Bvar. Artigas 789'), ('Lucía', 'Rodríguez', 'lucia.rodriguez@mail.com', '096333444', 'Av. Italia 321'), ('Pedro', 'Martínez', 'pedro.martinez@mail.com', '095555666', 'Camino Maldonado 654');
INSERT INTO personal (nombre, apellido, cargo, email, telefono, fecha_ingreso) VALUES ('Ana', 'Suárez', 'Vendedora', 'ana.suarez@mail.com', '099888777', '2022-01-10'), ('Luis', 'Torres', 'Gerente', 'luis.torres@mail.com', '098999888', '2021-03-15'), ('Sofía', 'López', 'Administrativa', 'sofia.lopez@mail.com', '097777666', '2023-06-01');
INSERT INTO productos (nombre_producto, id_categoria, id_marca, material, precio, tipo) VALUES ('Anillo Oro 18k', 1, 2, 'Oro', 1500.00, 'Anillo'), ('Cadena Plata Italiana', 2, 3, 'Plata', 800.00, 'Cadena'), ('Pulsera Acero', 3, 4, 'Acero', 300.00, 'Pulsera'), ('Aros Diamante', 4, 2, 'Oro', 2500.00, 'Aro'), ('Reloj Clásico', 5, 4, 'Acero', 1200.00, 'Reloj');
INSERT INTO inventario (id_producto, cantidad_disponible, ultima_actualizacion) VALUES (1, 10, CURDATE()), (2, 15, CURDATE()), (3, 8, CURDATE()), (4, 5, CURDATE()), (5, 12, CURDATE());
INSERT INTO proveedores (nombre_proveedor, telefono, email) VALUES ('Joyas SA', '29001234', 'contacto@joyassa.com'), ('Distribuidora Oro', '29005678', 'ventas@distribuidoraoro.com');
INSERT INTO compras (fecha_compra, id_proveedor, total) VALUES ('2024-11-10', 1, 5000.00), ('2024-11-15', 2, 3000.00);
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario) VALUES (1, 1, 5, 1400.00), (1, 2, 10, 750.00), (2, 4, 3, 2400.00);
INSERT INTO ventas (fecha_venta, id_cliente, id_personal, total) VALUES ('2024-12-01 10:30:00', 1, 1, 2300.00), ('2024-12-02 15:10:00', 2, 2, 1200.00), ('2024-12-03 11:05:00', 3, NULL, 800.00), ('2024-12-05 16:40:00', 4, 1, 2500.00);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (1, 1, 1, 1500.00), (1, 2, 1, 800.00), (2, 5, 1, 1200.00), (3, 2, 1, 800.00), (4, 4, 1, 2500.00);
INSERT INTO pagos_venta (id_venta, id_metodo_pago, monto, fecha_pago) VALUES (1, 2, 2300.00, '2024-12-01 10:35:00'), (2, 1, 1200.00, '2024-12-02 15:15:00'), (3, 4, 800.00, '2024-12-03 11:10:00'), (4, 2, 1500.00, '2024-12-05 16:45:00'), (4, 1, 1000.00, '2024-12-05 16:50:00');
INSERT INTO asistencia (id_personal, fecha, hora_entrada, hora_salida, estado) VALUES (1, '2024-12-01', '09:00:00', '18:00:00', 'Presente'), (2, '2024-12-01', '09:30:00', '18:30:00', 'Presente');
-- CALL sp_productos_stock_bajo(5);
-- CALL sp_ranking_productos_mes(2024, 12);
-- SELECT fn_total_cliente(1) AS total_cliente_1;
-- CALL sp_actualizar_precio_producto(3, 350.00, 'Ajuste por lista proveedor');
