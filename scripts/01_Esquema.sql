CREATE TABLE Rol (id_rol INT PRIMARY KEY, nombre VARCHAR(50) NOT NULL UNIQUE);
CREATE TABLE Empleado (id_empleado SERIAL PRIMARY KEY, nombre VARCHAR(100) NOT NULL, id_rol INT NOT NULL, FOREIGN KEY (id_rol) REFERENCES Rol(id_rol) ON UPDATE CASCADE);
CREATE TABLE Maquina (id_maquina SERIAL PRIMARY KEY, codigo VARCHAR(20) NOT NULL UNIQUE, nombre VARCHAR(50) NOT NULL);
CREATE TABLE Referencia (id_referencia SERIAL PRIMARY KEY, codigo VARCHAR(20) NOT NULL UNIQUE, nombre VARCHAR(100) NOT NULL);
CREATE TABLE Turno (id_turno INT PRIMARY KEY, descripcion VARCHAR(50) NOT NULL);
CREATE TABLE Codigo_Paro (id_codigo INT PRIMARY KEY, descripcion VARCHAR(150) NOT NULL);
CREATE TABLE Subcodigo_Paro (id_subcodigo SERIAL PRIMARY KEY, id_codigo INT NOT NULL, descripcion VARCHAR(150) NOT NULL, FOREIGN KEY (id_codigo) REFERENCES Codigo_Paro(id_codigo) ON DELETE CASCADE);
CREATE TABLE Registro_Produccion (id_registro SERIAL PRIMARY KEY, fecha DATE NOT NULL DEFAULT CURRENT_DATE, id_maquina INT NOT NULL, id_turno INT NOT NULL, id_operario INT NOT NULL, id_registrador INT NOT NULL, id_referencia INT NOT NULL, horas_trabajadas DECIMAL(5,2) NOT NULL DEFAULT 8.00 CHECK (horas_trabajadas >= 0), meta_hora INT NOT NULL CHECK (meta_hora > 0), pacas_producidas INT NOT NULL CHECK (pacas_producidas >= 0), FOREIGN KEY (id_maquina) REFERENCES Maquina(id_maquina), FOREIGN KEY (id_turno) REFERENCES Turno(id_turno), FOREIGN KEY (id_operario) REFERENCES Empleado(id_empleado), FOREIGN KEY (id_registrador) REFERENCES Empleado(id_empleado), FOREIGN KEY (id_referencia) REFERENCES Referencia(id_referencia));
CREATE TABLE Detalle_Paro (id_detalle SERIAL PRIMARY KEY, id_registro INT NOT NULL, id_codigo INT NOT NULL, id_subcodigo INT, horas_paro DECIMAL(5,2) NOT NULL CHECK (horas_paro > 0), observacion TEXT, FOREIGN KEY (id_registro) REFERENCES Registro_Produccion(id_registro) ON DELETE CASCADE, FOREIGN KEY (id_codigo) REFERENCES Codigo_Paro(id_codigo), FOREIGN KEY (id_subcodigo) REFERENCES Subcodigo_Paro(id_subcodigo));

CREATE VIEW vw_productividad_mensual AS SELECT m.nombre AS maquina, EXTRACT(YEAR FROM r.fecha) AS anio, EXTRACT(MONTH FROM r.fecha) AS mes, SUM(r.pacas_producidas) AS total_producido, SUM(r.horas_trabajadas * r.meta_hora) AS meta_esperada, ROUND((SUM(r.pacas_producidas)::numeric / NULLIF(SUM(r.horas_trabajadas * r.meta_hora), 0)) * 100, 2) AS porcentaje_productividad FROM Registro_Produccion r JOIN Maquina m ON r.id_maquina = m.id_maquina GROUP BY m.nombre, EXTRACT(YEAR FROM r.fecha), EXTRACT(MONTH FROM r.fecha);
CREATE VIEW vw_participacion_paros AS SELECT c.id_codigo, c.descripcion, SUM(d.horas_paro) AS total_horas, ROUND((SUM(d.horas_paro) / (SELECT SUM(horas_paro) FROM Detalle_Paro)) * 100, 2) AS porcentaje_participacion FROM Detalle_Paro d JOIN Codigo_Paro c ON d.id_codigo = c.id_codigo GROUP BY c.id_codigo, c.descripcion;

INSERT INTO Rol (id_rol, nombre) VALUES (1, 'Operario'), (2, 'Supervisor');
INSERT INTO Empleado (nombre, id_rol) VALUES ('Juan Pérez', 1), ('Ana Gómez', 1), ('Carlos Ruiz', 2);
INSERT INTO Maquina (codigo, nombre) VALUES ('MQ-01', 'Empacadora Principal'), ('MQ-02', 'Selladora B');
INSERT INTO Referencia (codigo, nombre) VALUES ('REF-100', 'Paca de 500g'), ('REF-200', 'Paca de 1kg');
INSERT INTO Turno (id_turno, descripcion) VALUES (1, 'Mañana (6am - 2pm)'), (2, 'Tarde (2pm - 10pm)');
INSERT INTO Codigo_Paro (id_codigo, descripcion) VALUES (1, 'Falla Mecánica'), (2, 'Falta de Materiales');
INSERT INTO Subcodigo_Paro (id_codigo, descripcion) VALUES (1, 'Atasco en la banda transportadora'), (2, 'Bobina de plástico agotada');
INSERT INTO Registro_Produccion (fecha, id_maquina, id_turno, id_operario, id_registrador, id_referencia, horas_trabajadas, meta_hora, pacas_producidas) VALUES ('2023-10-01', 1, 1, 1, 3, 1, 8.00, 100, 750), ('2023-10-01', 2, 2, 2, 3, 2, 8.00, 50, 420);
INSERT INTO Detalle_Paro (id_registro, id_codigo, id_subcodigo, horas_paro, observacion) VALUES (1, 1, 1, 0.50, 'Se trabó un engranaje principal'), (2, 2, 2, 1.00, 'El proveedor llegó tarde con el rollo');
