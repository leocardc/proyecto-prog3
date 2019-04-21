-- TDBSystem (Base de datos para el Sistema "Tienda de Barrio"), versión 0.6
-- Un simple modelo de bases de datos para fines académicos
-- Cree una base de datos Postgres en blanco y corra este script sobre ella.

-- Enseguida, se usa DDL (Data Definition Language) para crear la base de datos

DROP TABLE IF EXISTS categorias_productos CASCADE;
DROP TABLE IF EXISTS presentaciones_productos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS bajas_productos;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS pagos_clientes;
DROP TABLE IF EXISTS personal CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS pagos_proveedores;
DROP TABLE IF EXISTS ventas CASCADE;
DROP TABLE IF EXISTS detalles_ventas;
DROP TABLE IF EXISTS devoluciones_ventas CASCADE;
DROP TABLE IF EXISTS detalles_devoluciones_ventas;
DROP TABLE IF EXISTS compras CASCADE;
DROP TABLE IF EXISTS detalles_compras;
DROP TABLE IF EXISTS devoluciones_compras CASCADE;
DROP TABLE IF EXISTS detalles_devoluciones_compras;

DROP VIEW IF EXISTS lista_devoluciones_ventas CASCADE;
DROP VIEW IF EXISTS lista_detalles_ventas CASCADE;
DROP VIEW IF EXISTS lista_detalles_ventas_agrupadas CASCADE;
DROP VIEW IF EXISTS lista_devoluciones_ventas_agrupadas CASCADE;
DROP VIEW IF EXISTS lista_productos CASCADE;

DROP FUNCTION IF EXISTS insertar_producto CASCADE;
DROP FUNCTION IF EXISTS insertar_venta CASCADE;
DROP FUNCTION IF EXISTS insertar_presentacion CASCADE;
DROP FUNCTION IF EXISTS insertar_categoria CASCADE;
DROP FUNCTION IF EXISTS maximo;
DROP FUNCTION IF EXISTS insertar_pago_cliente;
DROP FUNCTION IF EXISTS insertar_baja_producto;
DROP FUNCTION IF EXISTS insertar_compra;
DROP FUNCTION IF EXISTS insertar_devolucion_venta;

DROP TYPE IF EXISTS tipo_detalle CASCADE;

CREATE TABLE categorias_productos (
	id_categoria_producto SMALLSERIAL NOT NULL,
	nombre varchar NOT NULL UNIQUE,
	PRIMARY KEY(id_categoria_producto)
);

CREATE TABLE presentaciones_productos (
	id_presentacion_producto SMALLSERIAL NOT NULL,
	descripcion varchar NOT NULL UNIQUE,
	PRIMARY KEY(id_presentacion_producto)
);

CREATE TABLE productos (
	id_producto SERIAL NOT NULL,
	nombre varchar NOT NULL UNIQUE,
	precio numeric NOT NULL DEFAULT 0,
	iva numeric NOT NULL DEFAULT 0.0,
	cantidad_disponible int2 NOT NULL DEFAULT 0,
	cantidad_minima int2 NOT NULL DEFAULT 1,
	cantidad_maxima int2 NOT NULL DEFAULT 1,
	id_presentacion_producto int2 NOT NULL,
	id_categoria_producto int2 NOT NULL,
	PRIMARY KEY(id_producto),
	CONSTRAINT ref_producto__categoria_producto FOREIGN KEY (id_categoria_producto)
		REFERENCES categorias_productos(id_categoria_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_producto__presentacion_producto FOREIGN KEY (id_presentacion_producto)
		REFERENCES presentaciones_productos(id_presentacion_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE bajas_productos (
	id_baja_producto SERIAL NOT NULL,
	tipo_baja varchar NOT NULL,
	fecha date NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	precio numeric NOT NULL DEFAULT 0,
	id_producto int4 NOT NULL,
	PRIMARY KEY(id_baja_producto),
	CONSTRAINT tipos_bajas CHECK (tipo_baja IN ('Donación', 'Daño', 'Pérdida', 'Descomposición', 'Destrucción', 'Exclusión')),
	CONSTRAINT ref_baja_productos__producto FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE clientes (
	id_cliente varchar NOT NULL,
	nombre varchar NOT NULL,
	telefonos varchar,
	direccion varchar,
	con_credito bool NOT NULL,
	PRIMARY KEY(id_cliente)
);

CREATE TABLE pagos_clientes (
	id_pago_cliente SERIAL NOT NULL,
	id_cliente varchar NOT NULL,
	valor_pago numeric NOT NULL DEFAULT 0,
	fecha_pago date NOT NULL,
	PRIMARY KEY(id_pago_cliente),
	CONSTRAINT ref_pago_cliente__cliente FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE personal (
	id_persona varchar NOT NULL,
	nombre varchar NOT NULL,
	telefono varchar NOT NULL,
	direccion varchar NOT NULL,
	perfil varchar NOT NULL,
	contrasena varchar NOT NULL,
	PRIMARY KEY(id_persona),
	CONSTRAINT tipo_perfil CHECK (perfil IN('Administrador', 'Vendedor'))
);

CREATE TABLE proveedores (
	id_proveedor varchar NOT NULL,
	nombre varchar NOT NULL,
	telefono varchar NOT NULL,
	correo varchar,
	PRIMARY KEY(id_proveedor)
);

CREATE TABLE pagos_proveedores (
	id_pago_proveedor SERIAL NOT NULL,
	id_proveedor varchar NOT NULL,
	valor_pago numeric NOT NULL DEFAULT 0,
	fecha_pago date NOT NULL,
	PRIMARY KEY(id_pago_proveedor),
	CONSTRAINT ref_pago_proveedor__proveedor FOREIGN KEY (id_proveedor)
		REFERENCES proveedores(id_proveedor)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE ventas (
	id_venta SERIAL NOT NULL,
	fecha_venta date NOT NULL,
	total_credito numeric NOT NULL DEFAULT 0,
	total_contado numeric NOT NULL DEFAULT 0,
	id_cliente varchar NOT NULL,
	id_vendedor varchar NOT NULL,
	PRIMARY KEY(id_venta),
	CONSTRAINT ref_venta__cliente FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_venta__personal FOREIGN KEY (id_vendedor)
		REFERENCES personal(id_persona)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_ventas (
	id_detalle_venta SERIAL NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	valor_producto numeric NOT NULL DEFAULT 0,
	descuento numeric NOT NULL DEFAULT 0,
	iva numeric NOT NULL DEFAULT 0,
	id_venta int4 NOT NULL,
	id_producto int4 NOT NULL,
	PRIMARY KEY(id_detalle_venta),
	CONSTRAINT ref_detalle_venta_a_venta FOREIGN KEY (id_venta)
		REFERENCES ventas(id_venta)
	MATCH SIMPLE
	ON DELETE CASCADE
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_detalle_venta__producto FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto)
	MATCH SIMPLE
	ON DELETE CASCADE
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

-- COMMENT ON COLUMN detalles_ventas.valor_producto IS 'debe permitir cálculo y entrada directa';

CREATE TABLE devoluciones_ventas (
	id_devolucion_venta SERIAL NOT NULL,
	id_venta int4 NOT NULL,
	fecha date NOT NULL,
	PRIMARY KEY(id_devolucion_venta),
	CONSTRAINT ref_devolucion_venta__venta FOREIGN KEY (id_venta)
		REFERENCES ventas(id_venta)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_devoluciones_ventas (
	id_detalle_devolucion_venta SERIAL NOT NULL,
	id_devolucion_venta int4 NOT NULL,
	id_producto int4 NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	PRIMARY KEY(id_detalle_devolucion_venta),
	CONSTRAINT ref_detalle_devolucion__devolucion_venta FOREIGN KEY (id_devolucion_venta)
		REFERENCES devoluciones_ventas(id_devolucion_venta)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE compras (
	id_compra SERIAL NOT NULL,
	fecha_compra date NOT NULL,
	fecha_recibido date NOT NULL,
	total_credito numeric NOT NULL DEFAULT 0,
	total_contado numeric NOT NULL DEFAULT 0,
	id_proveedor varchar NOT NULL,
	PRIMARY KEY(id_compra),
	CONSTRAINT ref_compra__proveedor FOREIGN KEY (id_proveedor)
		REFERENCES proveedores(id_proveedor)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_compras (
	id_detalle_compra SERIAL NOT NULL,
	cantidad_pedida int2 NOT NULL DEFAULT 0,
	cantidad_recibida int2 NOT NULL DEFAULT 0,
	valor_producto numeric NOT NULL DEFAULT 0,
	iva numeric DEFAULT 0,
	id_compra int4 NOT NULL,
	id_producto int4 NOT NULL,
	PRIMARY KEY(id_detalle_compra),
	CONSTRAINT ref_detalle_compra__compra FOREIGN KEY (id_compra)
		REFERENCES compras(id_compra)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_detalle_compra__presentacion_producto FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE devoluciones_compras (
	id_devolucion_compra SERIAL NOT NULL,
	id_compra int4 NOT NULL,
	fecha_devolucion date NOT NULL,
	PRIMARY KEY(id_devolucion_compra),
	CONSTRAINT ref_devolucion_pedido_a_pedido FOREIGN KEY (id_compra)
		REFERENCES compras(id_compra)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_devoluciones_compras (
	id_detalle_devolucion_compra SERIAL NOT NULL,
	id_devolucion_compra int4 NOT NULL,
	id_producto int4 NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	PRIMARY KEY(id_detalle_devolucion_compra),
	CONSTRAINT ref_detalle_devolucion_pedido__devolucion_pedido FOREIGN KEY (id_devolucion_compra)
		REFERENCES devoluciones_compras(id_devolucion_compra)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

-- A continuación algunas instrucciones DML disponibles mediante vistas o procedimientos almacenados
								  
CREATE OR REPLACE VIEW lista_productos AS										  
	SELECT 	c.id_categoria_producto,
				c.nombre categoria,
				pp.id_presentacion_producto,
				pp.descripcion presentacion,
				p.id_producto,
				p.nombre nombre,	
				p.nombre || ' ' || pp.descripcion descripcion_producto,
				iva porcentaje_iva,
				p.precio,
				p.cantidad_disponible,									  
				p.cantidad_minima,									  
				p.cantidad_maxima									  
			FROM productos p
				INNER JOIN categorias_productos c ON p.id_categoria_producto = c.id_categoria_producto
				INNER JOIN presentaciones_productos pp ON p.id_presentacion_producto = pp.id_presentacion_producto
			ORDER BY p.nombre, pp.descripcion;

CREATE OR REPLACE VIEW lista_detalles_ventas AS
 SELECT v.id_venta,
    v.fecha_venta,
    dv.id_detalle_venta,
    dv.id_producto AS producto,
    lp.descripcion_producto,
    dv.cantidad AS vendido,
    dv.valor_producto,
    dv.cantidad::numeric * dv.valor_producto AS total_linea
   FROM detalles_ventas dv
     JOIN lista_productos lp ON dv.id_producto = lp.id_producto
     JOIN ventas v ON v.id_venta = dv.id_venta;

CREATE OR REPLACE VIEW lista_detalles_ventas_agrupadas AS
 SELECT ldv.id_venta,
    ldv.fecha_venta,
    ldv.producto,
    ldv.descripcion_producto,
    sum(ldv.vendido) AS vendido,
    ldv.valor_producto
   FROM lista_detalles_ventas ldv
  GROUP BY ldv.id_venta, ldv.fecha_venta, ldv.producto, ldv.descripcion_producto, ldv.valor_producto;
	
CREATE OR REPLACE VIEW lista_devoluciones_ventas AS
 SELECT v.id_venta,
    dv.id_devolucion_venta,
    dv.fecha AS fecha_devolucion,
    ddv.id_detalle_devolucion_venta,
    ddv.id_producto,
    lp.descripcion_producto,
    ddv.cantidad AS cantidad_devuelta,
    lp.precio
   FROM detalles_devoluciones_ventas ddv
     JOIN devoluciones_ventas dv ON ddv.id_devolucion_venta = dv.id_devolucion_venta
     JOIN lista_productos lp ON ddv.id_producto = lp.id_producto
     JOIN ventas v ON dv.id_venta = v.id_venta;

CREATE OR REPLACE VIEW lista_devoluciones_ventas_agrupadas AS
 SELECT l.id_venta,
    l.fecha_devolucion,
    l.id_producto,
    l.descripcion_producto,
    sum(l.cantidad_devuelta) AS total_devuelto,
    l.precio
   FROM lista_devoluciones_ventas l
  GROUP BY l.id_venta, l.fecha_devolucion, l.id_producto, l.descripcion_producto, l.precio;

CREATE OR REPLACE VIEW lista_detalles_compras AS
 SELECT c.id_compra,
    c.fecha_compra,
    dc.id_detalle_compra,
    dc.id_producto AS producto,
    lp.descripcion_producto,
    dc.cantidad_pedida,
	dc.cantidad_recibida,
    dc.valor_producto,
    dc.cantidad_recibida::numeric * dc.valor_producto AS total_linea
   FROM detalles_compras dc
     JOIN lista_productos lp ON dc.id_producto = lp.id_producto
     JOIN compras c ON c.id_compra = dc.id_compra;
	 
CREATE OR REPLACE VIEW lista_devoluciones_compras AS
 SELECT c.id_compra,
    dc.id_devolucion_compra,
    dc.fecha_devolucion,
    ddc.id_detalle_devolucion_compra,
    ddc.id_producto,
    lp.descripcion_producto,
    ddc.cantidad,
    lp.precio
   FROM detalles_devoluciones_compras ddc
     JOIN devoluciones_compras dc ON ddc.id_devolucion_compra = dc.id_devolucion_compra
     JOIN lista_productos lp ON ddc.id_producto = lp.id_producto
     JOIN compras c ON dc.id_compra = c.id_compra;
	 
CREATE OR REPLACE VIEW lista_detalles_compras_agrupadas AS
 SELECT ldc.id_compra,
    ldc.fecha_compra,
    ldc.producto,
    ldc.descripcion_producto,
    sum(ldc.cantidad_recibida) AS recibido,
    ldc.valor_producto
   FROM lista_detalles_compras ldc
  GROUP BY ldc.id_compra, ldc.fecha_compra, ldc.producto, ldc.descripcion_producto, ldc.valor_producto;

CREATE OR REPLACE VIEW lista_devoluciones_compras_agrupadas AS
 SELECT l.id_compra,
    l.fecha_devolucion,
    l.id_producto,
    l.descripcion_producto,
    sum(l.cantidad) AS total_devuelto,
    l.precio
   FROM lista_devoluciones_compras l
  GROUP BY l.id_compra, l.fecha_devolucion, l.id_producto, l.descripcion_producto, l.precio;

CREATE OR REPLACE FUNCTION insertar_presentacion(descripcion_presentacion character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idpresentacion integer;
BEGIN
	idpresentacion = 0;
	
	INSERT INTO presentaciones_productos(descripcion) VALUES (descripcion_presentacion)
		RETURNING id_presentacion_producto into idpresentacion;
	RETURN idpresentacion;
END;
$BODY$;
	
CREATE OR REPLACE FUNCTION insertar_categoria(nombre_categoria character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idcategoria integer;
BEGIN
	idcategoria = 0;
	
	INSERT INTO categorias_productos(nombre) VALUES (nombre_categoria)
		RETURNING id_categoria_producto into idcategoria;
	RETURN idcategoria;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_producto(
	nombre_producto character varying,
	precio_producto numeric,
	porcentaje_iva numeric,
	disponible integer,
	minimo integer,
	maximo integer,
	id_presentacion integer,
	id_categoria integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idproducto integer;
BEGIN
	idproducto = 0;
	
	INSERT INTO productos(
		nombre, precio, iva, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
		VALUES (nombre_producto, precio_producto, porcentaje_iva, disponible, minimo, maximo, id_presentacion, id_categoria)
		RETURNING id_producto into idproducto;
	RETURN idproducto;
END;
$BODY$;

-- determina cuál es el máximo valor de una columna de tipo entero en cualquier tabla
CREATE OR REPLACE FUNCTION maximo(
	tabla character varying,
	columna character varying) RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      existe boolean;
	  ultimo integer;
	  sql varchar;
BEGIN
    -- https://www.postgresql.org/docs/current/functions-string.html#FUNCTIONS-STRING-FORMAT
	EXECUTE format('SELECT COUNT(*) > 0 FROM information_schema.columns WHERE table_name = %L and column_name = %L',
				   tabla, columna) INTO existe;
	IF existe THEN
		EXECUTE format('SELECT MAX(%s) FROM %s', columna, tabla) INTO ultimo;
		IF ultimo IS NULL THEN
			ultimo = 0;
		END IF;
		RETURN ultimo;
	ELSE
		RAISE EXCEPTION 'Tabla o columna errónea: % | %', tabla, columna;
	END IF;
END;
$BODY$;

-- Un bloque anónimo para la creación controlada de un tipos necesario para la inserción de detalles de ventas/compras
-- y l inserción de devoluciones ventas/compras

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_detalle') THEN
        CREATE TYPE tipo_detalle AS (
			cantidad integer, 
			cantidad_pedida integer, 
			cantidad_recibida integer, 
			producto varchar, 
			valor numeric, 
			iva_porcentaje numeric, 
			iva_valor numeric, 
			subtotal numeric
		);
    END IF;
END$$;

-- la función que registra la venta, los detalles de venta y afecta el stock de productos

CREATE OR REPLACE FUNCTION insertar_venta(datos_venta JSON)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	i INTEGER;
	idventa INTEGER;
	idproducto INTEGER;
	fecha DATE;
	cliente VARCHAR;
	vendedor VARCHAR;
	total NUMERIC;
	iva NUMERIC;
	paga NUMERIC;
	credito NUMERIC;
	linea_venta RECORD;
BEGIN
	idventa = 0;
	-- transfiere a variables las propiedades del objeto JSON 'datos_venta', excepto el array 'detalle'
	SELECT (datos_venta#>>'{fecha}')::DATE FROM json_each(datos_venta) WHERE key = 'fecha' INTO fecha;
	SELECT (datos_venta#>>'{cliente}')::VARCHAR FROM json_each(datos_venta) WHERE key = 'cliente' INTO cliente;
	SELECT (datos_venta#>>'{vendedor}')::VARCHAR FROM json_each(datos_venta) WHERE key = 'vendedor' INTO vendedor;
	SELECT (datos_venta#>>'{total}')::FLOAT FROM json_each(datos_venta) WHERE key = 'total' INTO total;
	SELECT (datos_venta#>>'{iva}')::FLOAT FROM json_each(datos_venta) WHERE key = 'iva' INTO iva;
	SELECT (datos_venta#>>'{paga}')::FLOAT FROM json_each(datos_venta) WHERE key = 'paga' INTO paga;
	
	credito = total - paga;
	
	INSERT INTO ventas(fecha_venta, total_credito, total_contado, id_cliente, id_vendedor)
		VALUES (fecha, credito, paga, cliente, vendedor) 
		RETURNING id_venta INTO idventa;
	
	IF idventa > 0 THEN
		-- recorre las filas correspondientes a cada detalle de venta
		FOR linea_venta IN
			-- expande el array de objetos 'detalle' a un conjunto de filas de tipo 'tipo_detalle'
			SELECT * FROM json_populate_recordset(null::tipo_detalle, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_venta) WHERE key = 'detalle')
			) LOOP
			
			i = strpos(linea_venta.producto, '-') - 1;
			idproducto = substr(linea_venta.producto, 1, i);
			
			-- por cada detalle, inserta una línea de venta. Esta versión NO maneja descuentos (0.0)
			INSERT INTO detalles_ventas(cantidad, valor_producto, descuento, iva, id_venta, id_producto)
				VALUES (linea_venta.cantidad, linea_venta.valor, 0.0, linea_venta.iva_valor, idventa, idproducto);
			
			-- en productos, sustraer la cantidad vendida de la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible - linea_venta.cantidad 
				WHERE id_producto = idproducto;
		END LOOP;
	END IF;
	
	RETURN idventa;
END;
$BODY$;

-- la función que registra la compra, los detalles de compra y afecta el stock de productos

CREATE OR REPLACE FUNCTION insertar_compra(datos_compra JSON)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	i INTEGER;
	idcompra INTEGER;
	idproducto INTEGER;
	fechacompra DATE;
	fecharecibido DATE;
	proveedor VARCHAR;
	total NUMERIC;
	iva NUMERIC;
	paga NUMERIC;
	credito NUMERIC;
	linea_compra RECORD;
BEGIN
	idcompra = 0;
	-- transfiere a variables las propiedades del objeto JSON 'datos_compra', excepto el array 'detalle'
	SELECT (datos_compra#>>'{fecha_compra}')::DATE FROM json_each(datos_compra) WHERE key = 'fecha_compra' INTO fechacompra;
	SELECT (datos_compra#>>'{fecha_recibido}')::DATE FROM json_each(datos_compra) WHERE key = 'fecha_recibido' INTO fecharecibido;
	SELECT (datos_compra#>>'{proveedor}')::VARCHAR FROM json_each(datos_compra) WHERE key = 'proveedor' INTO proveedor;
	SELECT (datos_compra#>>'{total}')::FLOAT FROM json_each(datos_compra) WHERE key = 'total' INTO total;
	SELECT (datos_compra#>>'{iva}')::FLOAT FROM json_each(datos_compra) WHERE key = 'iva' INTO iva;
	SELECT (datos_compra#>>'{paga}')::FLOAT FROM json_each(datos_compra) WHERE key = 'paga' INTO paga;

	credito = total - paga;
	
	INSERT INTO compras(fecha_compra, fecha_recibido, total_credito, total_contado, id_proveedor)
		VALUES (fechacompra, fecharecibido, credito, paga, proveedor)
		RETURNING id_compra INTO idcompra;
	
	IF idcompra > 0 THEN
		-- recorre las filas correspondientes a cada detalle de compra
		FOR linea_compra IN
			-- expande el array de objetos 'detalle' a un conjunto de filas de tipo 'tipo_detalle'
			SELECT * FROM json_populate_recordset(null::tipo_detalle, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_compra) WHERE key = 'detalle')
			) LOOP

			i = strpos(linea_compra.producto, '-') - 1;
			idproducto = substr(linea_compra.producto, 1, i);
			
			-- por cada detalle, inserta una línea de compra. Esta versión NO maneja descuentos (0.0)
			INSERT INTO detalles_compras(cantidad_pedida, cantidad_recibida, valor_producto, iva, id_compra, id_producto)
				VALUES (linea_compra.cantidad_pedida, linea_compra.cantidad_recibida, linea_compra.valor, linea_compra.iva_valor, idcompra, idproducto);
			
			-- en productos, aumentar la cantidad comprada a la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible + linea_compra.cantidad_recibida
				WHERE id_producto = idproducto;
		END LOOP;
	END IF;
	
	RETURN idcompra;
END;
$BODY$;

-- la función que registra devoluciones por venta, los detalles de devolución por ventas y afecta el stock de productos

CREATE OR REPLACE FUNCTION insertar_devolucion_venta(datos_devolucion JSON)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	i INTEGER;
	iddevolucion INTEGER;
	idproducto INTEGER;
	fecha DATE;
	venta INTEGER;
	linea_devolucion RECORD;
BEGIN
	iddevolucion = 0;
	-- transfiere a variables las propiedades del objeto JSON 'datos_devolucion', excepto el array 'detalle'
	SELECT (datos_devolucion#>>'{fecha}')::DATE FROM json_each(datos_devolucion) WHERE key = 'fecha' INTO fecha;
	SELECT (datos_devolucion#>>'{venta}')::INTEGER FROM json_each(datos_devolucion) WHERE key = 'venta' INTO venta;
	
	INSERT INTO devoluciones_ventas(id_venta, fecha) VALUES (venta, fecha) RETURNING id_devolucion_venta INTO iddevolucion;
	
	IF iddevolucion > 0 THEN
		-- recorre las filas correspondientes a cada detalle de devoluciones por venta
		FOR linea_devolucion IN
			-- expande el array de objetos 'detalle' a un conjunto de filas de tipo 'tipo_detalle'
			SELECT * FROM json_populate_recordset(null::tipo_detalle, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_devolucion) WHERE key = 'detalle')
			) LOOP
			
			idproducto = linea_devolucion.producto::integer; -- un cast de varchar a integer
			
			-- por cada detalle, inserta una línea de devolucion.
			INSERT INTO detalles_devoluciones_ventas(id_devolucion_venta, id_producto, cantidad)
				VALUES (iddevolucion, idproducto, linea_devolucion.cantidad);

			-- en productos, agregar la cantidad devuelta a la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible + linea_devolucion.cantidad 
				WHERE id_producto = idproducto;
		END LOOP;
	END IF;
	
	RETURN iddevolucion;
END;
$BODY$;

-- la función que registra devoluciones por venta, los detalles de devolución por ventas y afecta el stock de productos

CREATE OR REPLACE FUNCTION insertar_devolucion_compra(datos_devolucion JSON)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	i INTEGER;
	iddevolucion INTEGER;
	idproducto INTEGER;
	fecha DATE;
	compra INTEGER;
	linea_devolucion RECORD;
BEGIN
	iddevolucion = 0;
	-- transfiere a variables las propiedades del objeto JSON 'datos_devolucion', excepto el array 'detalle'
	SELECT (datos_devolucion#>>'{fecha}')::DATE FROM json_each(datos_devolucion) WHERE key = 'fecha' INTO fecha;
	SELECT (datos_devolucion#>>'{compra}')::INTEGER FROM json_each(datos_devolucion) WHERE key = 'compra' INTO compra;
	
	INSERT INTO devoluciones_compras(id_compra, fecha_devolucion) VALUES (compra, fecha) RETURNING id_devolucion_compra INTO iddevolucion;
	
	IF iddevolucion > 0 THEN
		-- recorre las filas correspondientes a cada detalle de devoluciones por compra
		FOR linea_devolucion IN
			-- expande el array de objetos 'detalle' a un conjunto de filas de tipo 'tipo_detalle'
			SELECT * FROM json_populate_recordset(null::tipo_detalle, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_devolucion) WHERE key = 'detalle')
			) LOOP
			
			idproducto = linea_devolucion.producto::integer; -- un cast de varchar a integer
			
			-- por cada detalle, inserta una línea de devolucion.
			INSERT INTO detalles_devoluciones_compras(id_devolucion_compra, id_producto, cantidad)
				VALUES (iddevolucion, idproducto, linea_devolucion.cantidad);

			-- en productos, agregar la cantidad devuelta a la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible - linea_devolucion.cantidad 
				WHERE id_producto = idproducto;
		END LOOP;
	END IF;
	
	RETURN iddevolucion;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_pago_cliente(cliente character varying, valor numeric, fecha date) RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idpago integer;
BEGIN
	idpago = 0;
	INSERT INTO pagos_clientes(id_cliente, valor_pago, fecha_pago) VALUES (cliente, valor, fecha)
		RETURNING id_pago_cliente into idpago;
	RETURN idpago;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_pago_proveedor(proveedor character varying, valor numeric, fecha date) RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idpago integer;
BEGIN
	idpago = 0;
	INSERT INTO pagos_proveedores(id_proveedor, valor_pago, fecha_pago) VALUES (proveedor, valor, fecha)
		RETURNING id_pago_proveedor into idpago;
	RETURN idpago;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_baja_producto(
	tipobaja character varying,
	fechabaja date,
	idproducto integer,
	cantidadbaja integer,
	precioproducto numeric) RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idbaja integer;
BEGIN
	idbaja = 0;

	INSERT INTO bajas_productos(
		tipo_baja, fecha, id_producto, cantidad, precio)
		VALUES (tipobaja, fechabaja, idproducto, cantidadbaja, precioproducto) 
		RETURNING id_baja_producto into idbaja;
	
	-- en productos, sustraer la cantidad de baja, de la cantidad_disponible 
	UPDATE productos SET cantidad_disponible = cantidad_disponible - cantidadbaja 
		WHERE id_producto = idproducto;
		
	RETURN idbaja;
END;
$BODY$;

----------------

-- A continuación un poco de Data Manipulation Language (DML) para disponer de algunas pruebas

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL001', 'Juan José Hernández Hernández', '8760001', 'Calle 10 # 11-11', true)
	ON CONFLICT DO NOTHING;	
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL002', 'Miguel Angel García García', '8760002', 'Calle 11 # 11-12', true)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL003', 'Juan Sebastián García García', '8760003', 'Calle 12 # 11-13', true)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL004', 'Juan David García Hernández', '8760004', 'Calle 13 # 11-14', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL005', 'Samuel David García García', '8760005', 'Calle 13 # 12-14', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL006', 'Juan Pablo García García', '8760006', 'Calle 13 # 12-15', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL007', 'Andrés Felipe García Martínez', '8760007', 'Calle 10 # 12-15', true)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL008', 'Juan Esteban Hernández Hernández', '8760008', 'Calle 12 # 11-15', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL009', 'Juan Diego Flores García', '8760009', 'Calle 10 # 11-15', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL010', 'Angel David García Hernández', '8760010', 'Calle 9 # 11-15', false)
	ON CONFLICT DO NOTHING;

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL011','Francisco Diaz Diaz','8530000','Cra. 4 #18-32',true)
	ON CONFLICT DO NOTHING;

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL012','Luciana Garcia Jimenez','8534523','Cra. 1#13-18',true)
	ON CONFLICT DO NOTHING;

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL013','Sofia Lopez Trejos','8532310','Cra. 5 #16-52',true)
	ON CONFLICT DO NOTHING;
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL014','Melissa Mesa Marin','8538975','Cra. 7 #20-25',true)
	ON CONFLICT DO NOTHING;
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL015','Nicole Torres Marin','8539632','Cra. 6 #18-41',true)
	ON CONFLICT DO NOTHING;
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL016','Sol Carvajal Mejia','8530000','Cra.1 #13-20',true)
	ON CONFLICT DO NOTHING;
	
-------------------------------------	

INSERT INTO categorias_productos(nombre) VALUES ('Lacteos') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Cárnicos') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Frutas') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Verduras') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Cereales') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Aseo personal') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Aseo del hogar') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Condimentos') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Bebidas') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Licores') ON CONFLICT DO NOTHING;

INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 1000 cc') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 12 unidades') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 500 gramos') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 1 kg') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Botella no retornable x 2.5 lt.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Botella no retornable x 1 lt.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Botella no retornable x 600 ml.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 5 kg. aprox.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Unidad') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Caja x 250 gramos') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Caja x 500 gramos') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Paquete x 3 Unidades') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Caja') ON CONFLICT DO NOTHING;

-------------------------------------	

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Leche Colanta', 2000, 19, 3, 20, 1, 1) 
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Lecha entera Celema', 1900, 150, 2, 15, 1, 1)
	 ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Mandarinas', 3000, 90, 3, 10, 2, 3)
	 ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Lentejas', 1000, 15, 5, 30, 3, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Arroz Doña Pepa', 1200, 80, 5, 25, 3, 5)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Maíz trillado', 900, 69, 3, 10, 4, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Lechuga', 1500, 79, 3, 10, 3, 4)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Kiwi', 2000, 39, 2, 9, 12, 3)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Maracuya', 3000, 180, 3, 10, 12, 3)
	ON CONFLICT DO NOTHING;
								  
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Cereal Madagascar', 3000, 90, 3, 10, 3, 5)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Cafe Monumental', 4500, 29, 5, 10, 3, 4)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Mantequilla Colanta', 3800, 55, 3, 10, 9, 4)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Jabon Ariel', 7800, 210, 3, 15, 4, 7)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Manzanas', 4500, 39, 3, 15, 12, 3)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Arroz Diana', 1500, 70, 10, 30, 3, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Frijol del Costal', 1500, 29, 5, 20, 3, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Mantequilla don Oleo', 3500, 50, 10, 20, 9, 4)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Crema de leche Colanta', 2200, 19, 10, 40, 3, 1)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Jabon en polvo Josefina', 4000, 30, 5, 20, 4, 7)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Crema dental Colgate', 1800, 19, 10, 20, 9, 6)
	ON CONFLICT DO NOTHING;
	
-------------------------------------	

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('001','Jorge Pérez','8530001','Cra.3#10-34','Administrador','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;
	
INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('002','Valeria Mejia Zapata','8536345','Cra.5#19-37','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;
	
INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('003','Juan Bermudez Duque','8531235','Cra.1#11-23','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('004','Carlos Franco','3237059840','Calle 15 #30-17','Administrador','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('005','Edgar Velez','3157059840','Calle 25 #32-17','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('006','Cristian Aristi','3183059840','Calle 95 #90-17','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('007','Jose Londoño','3111059840','Calle 65 #10-27','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('008','Juan Duran','3104059840','Calle 65 #50-57','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('009','Maria Gomez','3110059840','Calle 65 #30-10','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('010','Liliana Franco','3112059840','Calle 65 #30-40','Administrador','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('011','Ana Solarte','3135459840','Calle 65 #12-11','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('012','Josefa Franco','3106059840','Calle 65 #20-17','Vendedor','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('013','Jenny Franco','3114059840','Calle 65 #10-17','Administrador','$2y$10$H.j77qRgZ6gm7ua7vOciLOSr3JQiG3g7fa3RLxPcYv2HNObCn673y')
	ON CONFLICT DO NOTHING;

-------------------------------------	

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR01','Distribuidora Donde Pancho','7852212','dondepancho@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR02','Distribuidora Nuevo Sol','7852546','nuevosol@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR03','Lacteos Doña Vaca','7852345','vaca12@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR04','Granos La Cosecha','7852897','cose@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR05','Embutidos Don Chorizo','7652431','donchorizo@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR06','Fruteria Su Media Naranja','7552431','mimedianaranja@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR07','Productos y Productos SA','7752431','elproducto@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR08','Distribuidora ComaRico','7152431','comaricobien@gmail.com')
	ON CONFLICT DO NOTHING;
	
INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P005', 'Jader Raúl Gomez', '8783400', 'jadergomez@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P006', 'Juan Carmona', '8926241', 'juancarmona@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P007', 'Juan Diego Castaño', '8451201', 'diegocastño@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P008', 'Juliana Reyes', '8120167', 'julianareyes@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P009', 'Andres Calamaro', '8791203', 'andrescalamaro@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P010', 'Jaime Soto', '8916060', 'jaimesoto@gmail.com')
	ON CONFLICT DO NOTHING;		

 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-01","fecha_recibido":"2019-04-17","proveedor":"P009","total":"34200","iva":"0","paga":"20000","adeuda":"14200","detalle":[{"cantidad_pedida":"1","cantidad_recibida":"1","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"},{"cantidad_pedida":"4","cantidad_recibida":"4","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31200"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-01","fecha_recibido":"2019-04-17","proveedor":"PR04","total":"10500","iva":"0","paga":"10500","adeuda":"0","detalle":[{"cantidad_pedida":"3","cantidad_recibida":"3","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"},{"cantidad_pedida":"6","cantidad_recibida":"6","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-01","fecha_recibido":"2019-04-22","proveedor":"P008","total":"131600","iva":"0","paga":"100000","adeuda":"31600","detalle":[{"cantidad_pedida":"20","cantidad_recibida":"20","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"38000"},{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"93600"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-02","fecha_recibido":"2019-04-10","proveedor":"P009","total":"278000","iva":"0","paga":"278000","adeuda":"0","detalle":[{"cantidad_pedida":"50","cantidad_recibida":"50","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"225000"},{"cantidad_pedida":"10","cantidad_recibida":"6","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad_pedida":"100","cantidad_recibida":"20","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"44000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-04","fecha_recibido":"2019-04-08","proveedor":"PR02","total":"43500","iva":"0","paga":"43500","adeuda":"0","detalle":[{"cantidad_pedida":"6","cantidad_recibida":"6","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad_pedida":"4","cantidad_recibida":"4","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad_pedida":"1","cantidad_recibida":"1","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-08","fecha_recibido":"2019-04-24","proveedor":"PR06","total":"101400","iva":"0","paga":"71850","adeuda":"29550","detalle":[{"cantidad_pedida":"15","cantidad_recibida":"8","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"62400"},{"cantidad_pedida":"13","cantidad_recibida":"13","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-09","fecha_recibido":"2019-04-23","proveedor":"PR01","total":"3700","iva":"0","paga":"3700","adeuda":"0","detalle":[{"cantidad_pedida":"3","cantidad_recibida":"1","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1500"},{"cantidad_pedida":"1","cantidad_recibida":"1","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2200"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P006","total":"103600","iva":"0","paga":"103600","adeuda":"0","detalle":[{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"78000"},{"cantidad_pedida":"14","cantidad_recibida":"13","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"},{"cantidad_pedida":"11","cantidad_recibida":"10","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P006","total":"29000","iva":"0","paga":"28500","adeuda":"500","detalle":[{"cantidad_pedida":"9","cantidad_recibida":"9","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad_pedida":"3","cantidad_recibida":"2","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P006","total":"293500","iva":"0","paga":"293500","adeuda":"0","detalle":[{"cantidad_pedida":"19","cantidad_recibida":"19","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"76000"},{"cantidad_pedida":"26","cantidad_recibida":"25","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"37500"},{"cantidad_pedida":"30","cantidad_recibida":"30","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"135000"},{"cantidad_pedida":"39","cantidad_recibida":"30","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P006","total":"52500","iva":"0","paga":"52500","adeuda":"0","detalle":[{"cantidad_pedida":"1","cantidad_recibida":"6","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad_pedida":"1","cantidad_recibida":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"1","cantidad_recibida":"7","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P007","total":"102600","iva":"0","paga":"102600","adeuda":"0","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"4","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad_pedida":"4","cantidad_recibida":"3","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6600"},{"cantidad_pedida":"20","cantidad_recibida":"20","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"90000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P007","total":"15900","iva":"0","paga":"15900","adeuda":"0","detalle":[{"cantidad_pedida":"7","cantidad_recibida":"7","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"},{"cantidad_pedida":"7","cantidad_recibida":"6","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5400"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P007","total":"44500","iva":"0","paga":"44500","adeuda":"0","detalle":[{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"22000"},{"cantidad_pedida":"8","cantidad_recibida":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"7","cantidad_recibida":"7","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P007","total":"54300","iva":"0","paga":"54300","adeuda":"0","detalle":[{"cantidad_pedida":"12","cantidad_recibida":"7","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6300"},{"cantidad_pedida":"9","cantidad_recibida":"6","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad_pedida":"15","cantidad_recibida":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"11","cantidad_recibida":"3","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad_pedida":"5","cantidad_recibida":"3","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P008","total":"224500","iva":"0","paga":"224500","adeuda":"0","detalle":[{"cantidad_pedida":"40","cantidad_recibida":"40","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"88000"},{"cantidad_pedida":"30","cantidad_recibida":"27","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"},{"cantidad_pedida":"50","cantidad_recibida":"48","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"96000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P009","total":"23000","iva":"0","paga":"23000","adeuda":"0","detalle":[{"cantidad_pedida":"9","cantidad_recibida":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"5","cantidad_recibida":"5","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P009","total":"73200","iva":"0","paga":"73200","adeuda":"0","detalle":[{"cantidad_pedida":"20","cantidad_recibida":"19","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"34200"},{"cantidad_pedida":"13","cantidad_recibida":"12","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad_pedida":"15","cantidad_recibida":"14","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P010","total":"110000","iva":"0","paga":"32000","adeuda":"1000","detalle":[{"cantidad_pedida":"13","cantidad_recibida":"11","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"33000"},{"cantidad_pedida":"31","cantidad_recibida":"22","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"77000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"P010","total":"75700","iva":"0","paga":"75700","adeuda":"0","detalle":[{"cantidad_pedida":"8","cantidad_recibida":"3","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2700"},{"cantidad_pedida":"16","cantidad_recibida":"15","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"60000"},{"cantidad_pedida":"13","cantidad_recibida":"13","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR02","total":"116400","iva":"0","paga":"116400","adeuda":"0","detalle":[{"cantidad_pedida":"11","cantidad_recibida":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"78000"},{"cantidad_pedida":"16","cantidad_recibida":"12","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"26400"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR02","total":"36000","iva":"0","paga":"35000","adeuda":"0","detalle":[{"cantidad_pedida":"45","cantidad_recibida":"35","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"35000"},{"cantidad_pedida":"4","cantidad_recibida":"1","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR03","total":"25500","iva":"0","paga":"13500","adeuda":"0","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"3","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad_pedida":"8","cantidad_recibida":"4","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR03","total":"42900","iva":"0","paga":"42900","adeuda":"0","detalle":[{"cantidad_pedida":"8","cantidad_recibida":"8","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17600"},{"cantidad_pedida":"7","cantidad_recibida":"6","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"7","cantidad_recibida":"7","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13300"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR03","total":"73500","iva":"0","paga":"73500","adeuda":"0","detalle":[{"cantidad_pedida":"6","cantidad_recibida":"6","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad_pedida":"15","cantidad_recibida":"5","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"},{"cantidad_pedida":"5","cantidad_recibida":"5","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR04","total":"37900","iva":"0","paga":"37900","adeuda":"0","detalle":[{"cantidad_pedida":"8","cantidad_recibida":"6","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad_pedida":"6","cantidad_recibida":"6","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11400"},{"cantidad_pedida":"5","cantidad_recibida":"5","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR04","total":"79000","iva":"0","paga":"79000","adeuda":"0","detalle":[{"cantidad_pedida":"8","cantidad_recibida":"7","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad_pedida":"6","cantidad_recibida":"5","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17500"},{"cantidad_pedida":"9","cantidad_recibida":"9","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR05","total":"14200","iva":"0","paga":"12000","adeuda":"0","detalle":[{"cantidad_pedida":"4","cantidad_recibida":"4","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad_pedida":"2","cantidad_recibida":"1","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2200"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR05","total":"47700","iva":"0","paga":"47700","adeuda":"0","detalle":[{"cantidad_pedida":"19","cantidad_recibida":"19","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"34200"},{"cantidad_pedida":"16","cantidad_recibida":"15","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR05","total":"57500","iva":"0","paga":"57500","adeuda":"0","detalle":[{"cantidad_pedida":"9","cantidad_recibida":"9","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad_pedida":"8","cantidad_recibida":"7","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"14000"},{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"30000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR06","total":"414000","iva":"0","paga":"339000","adeuda":"0","detalle":[{"cantidad_pedida":"70","cantidad_recibida":"69","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"207000"},{"cantidad_pedida":"50","cantidad_recibida":"33","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"132000"},{"cantidad_pedida":"59","cantidad_recibida":"50","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"75000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR06","total":"54500","iva":"0","paga":"54500","adeuda":"0","detalle":[{"cantidad_pedida":"9","cantidad_recibida":"8","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad_pedida":"7","cantidad_recibida":"7","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"},{"cantidad_pedida":"15","cantidad_recibida":"10","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"20000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR07","total":"33000","iva":"0","paga":"33000","adeuda":"0","detalle":[{"cantidad_pedida":"8","cantidad_recibida":"8","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"},{"cantidad_pedida":"7","cantidad_recibida":"5","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR07","total":"39000","iva":"0","paga":"30000","adeuda":"9000","detalle":[{"cantidad_pedida":"6","cantidad_recibida":"5","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR07","total":"42800","iva":"0","paga":"42800","adeuda":"0","detalle":[{"cantidad_pedida":"6","cantidad_recibida":"6","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad_pedida":"8","cantidad_recibida":"7","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"26600"},{"cantidad_pedida":"7","cantidad_recibida":"6","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7200"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR07","total":"56000","iva":"0","paga":"56000","adeuda":"0","detalle":[{"cantidad_pedida":"34","cantidad_recibida":"30","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"14","cantidad_recibida":"11","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR08","total":"157500","iva":"0","paga":"154898","adeuda":"2602","detalle":[{"cantidad_pedida":"40","cantidad_recibida":"34","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"153000"},{"cantidad_pedida":"3","cantidad_recibida":"3","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR08","total":"189000","iva":"0","paga":"150000","adeuda":"0","detalle":[{"cantidad_pedida":"36","cantidad_recibida":"20","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"90000"},{"cantidad_pedida":"42","cantidad_recibida":"40","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"60000"},{"cantidad_pedida":"26","cantidad_recibida":"26","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR08","total":"207000","iva":"0","paga":"108000","adeuda":"0","detalle":[{"cantidad_pedida":"50","cantidad_recibida":"36","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"108000"},{"cantidad_pedida":"23","cantidad_recibida":"22","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"99000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-10","proveedor":"PR08","total":"77900","iva":"0","paga":"77900","adeuda":"0","detalle":[{"cantidad_pedida":"7","cantidad_recibida":"6","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5400"},{"cantidad_pedida":"5","cantidad_recibida":"4","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad_pedida":"19","cantidad_recibida":"19","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"66500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-13","proveedor":"PR08","total":"14000","iva":"0","paga":"14000","adeuda":"0","detalle":[{"cantidad_pedida":"3","cantidad_recibida":"3","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad_pedida":"8","cantidad_recibida":"8","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-17","proveedor":"PR08","total":"23400","iva":"0","paga":"20000","adeuda":"3400","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"3","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"23400"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-10","fecha_recibido":"2019-04-24","proveedor":"PR01","total":"39000","iva":"0","paga":"30000","adeuda":"9000","detalle":[{"cantidad_pedida":"10","cantidad_recibida":"5","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P005","total":"129900","iva":"0","paga":"100500","adeuda":"29400","detalle":[{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"26400"},{"cantidad_pedida":"21","cantidad_recibida":"21","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"},{"cantidad_pedida":"71","cantidad_recibida":"60","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"72000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P005","total":"129900","iva":"0","paga":"100500","adeuda":"29400","detalle":[{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"26400"},{"cantidad_pedida":"21","cantidad_recibida":"21","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"},{"cantidad_pedida":"71","cantidad_recibida":"60","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"72000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P006","total":"75100","iva":"0","paga":"50000","adeuda":"25100","detalle":[{"cantidad_pedida":"2","cantidad_recibida":"2","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"},{"cantidad_pedida":"3","cantidad_recibida":"1","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1000"},{"cantidad_pedida":"13","cantidad_recibida":"13","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"58500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P006","total":"75100","iva":"0","paga":"50000","adeuda":"25100","detalle":[{"cantidad_pedida":"2","cantidad_recibida":"2","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"},{"cantidad_pedida":"3","cantidad_recibida":"1","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1000"},{"cantidad_pedida":"13","cantidad_recibida":"13","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"58500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P007","total":"73800","iva":"0","paga":"73800","adeuda":"0","detalle":[{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"32","cantidad_recibida":"32","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28800"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P007","total":"73800","iva":"0","paga":"73800","adeuda":"0","detalle":[{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"32","cantidad_recibida":"32","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28800"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P009","total":"44900","iva":"0","paga":"40000","adeuda":"4900","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"5","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad_pedida":"20","cantidad_recibida":"17","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"37400"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P009","total":"44900","iva":"0","paga":"40000","adeuda":"4900","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"5","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad_pedida":"20","cantidad_recibida":"17","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"37400"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P010","total":"123200","iva":"0","paga":"123200","adeuda":"0","detalle":[{"cantidad_pedida":"4","cantidad_recibida":"4","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"},{"cantidad_pedida":"64","cantidad_recibida":"64","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"115200"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"P010","total":"123200","iva":"0","paga":"123200","adeuda":"0","detalle":[{"cantidad_pedida":"4","cantidad_recibida":"4","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"},{"cantidad_pedida":"64","cantidad_recibida":"64","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"115200"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR04","total":"153500","iva":"0","paga":"145500","adeuda":"8000","detalle":[{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"},{"cantidad_pedida":"53","cantidad_recibida":"50","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"23","cantidad_recibida":"23","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"92000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR04","total":"153500","iva":"0","paga":"145500","adeuda":"8000","detalle":[{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"},{"cantidad_pedida":"53","cantidad_recibida":"50","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"23","cantidad_recibida":"23","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"92000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR04","total":"153500","iva":"0","paga":"145500","adeuda":"8000","detalle":[{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"},{"cantidad_pedida":"53","cantidad_recibida":"50","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"23","cantidad_recibida":"23","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"92000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR04","total":"153500","iva":"0","paga":"145500","adeuda":"8000","detalle":[{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"},{"cantidad_pedida":"53","cantidad_recibida":"50","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"23","cantidad_recibida":"23","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"92000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR04","total":"423500","iva":"0","paga":"423000","adeuda":"500","detalle":[{"cantidad_pedida":"64","cantidad_recibida":"63","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"283500"},{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"17","cantidad_recibida":"17","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"51000"},{"cantidad_pedida":"19","cantidad_recibida":"20","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"44000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR04","total":"423500","iva":"0","paga":"423000","adeuda":"500","detalle":[{"cantidad_pedida":"64","cantidad_recibida":"63","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"283500"},{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad_pedida":"17","cantidad_recibida":"17","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"51000"},{"cantidad_pedida":"19","cantidad_recibida":"20","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"44000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR05","total":"12300","iva":"0","paga":"12000","adeuda":"300","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"4","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad_pedida":"2","cantidad_recibida":"7","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6300"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR05","total":"12300","iva":"0","paga":"12000","adeuda":"300","detalle":[{"cantidad_pedida":"5","cantidad_recibida":"4","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad_pedida":"2","cantidad_recibida":"7","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6300"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR06","total":"265000","iva":"0","paga":"200000","adeuda":"65000","detalle":[{"cantidad_pedida":"89","cantidad_recibida":"80","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"120000"},{"cantidad_pedida":"50","cantidad_recibida":"50","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"100000"},{"cantidad_pedida":"15","cantidad_recibida":"15","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR06","total":"265000","iva":"0","paga":"200000","adeuda":"65000","detalle":[{"cantidad_pedida":"89","cantidad_recibida":"80","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"120000"},{"cantidad_pedida":"50","cantidad_recibida":"50","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"100000"},{"cantidad_pedida":"15","cantidad_recibida":"15","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR07","total":"76300","iva":"0","paga":"60000","adeuda":"16300","detalle":[{"cantidad_pedida":"43","cantidad_recibida":"40","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40000"},{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"},{"cantidad_pedida":"9","cantidad_recibida":"9","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"19800"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR07","total":"76300","iva":"0","paga":"60000","adeuda":"16300","detalle":[{"cantidad_pedida":"43","cantidad_recibida":"40","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40000"},{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"},{"cantidad_pedida":"9","cantidad_recibida":"9","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"19800"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR08","total":"103100","iva":"0","paga":"103100","adeuda":"0","detalle":[{"cantidad_pedida":"40","cantidad_recibida":"40","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"80000"},{"cantidad_pedida":"3","cantidad_recibida":"3","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6600"},{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-11","proveedor":"PR08","total":"103100","iva":"0","paga":"103100","adeuda":"0","detalle":[{"cantidad_pedida":"40","cantidad_recibida":"40","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"80000"},{"cantidad_pedida":"3","cantidad_recibida":"3","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6600"},{"cantidad_pedida":"11","cantidad_recibida":"11","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"16500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-13","proveedor":"P005","total":"75000","iva":"0","paga":"75000","adeuda":"0","detalle":[{"cantidad_pedida":"20","cantidad_recibida":"20","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"30000"},{"cantidad_pedida":"30","cantidad_recibida":"30","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-13","proveedor":"P008","total":"158000","iva":"0","paga":"100000","adeuda":"58000","detalle":[{"cantidad_pedida":"20","cantidad_recibida":"20","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"80000"},{"cantidad_pedida":"15","cantidad_recibida":"10","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"78000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-11","fecha_recibido":"2019-04-23","proveedor":"P010","total":"98000","iva":"0","paga":"50000","adeuda":"48000","detalle":[{"cantidad_pedida":"30","cantidad_recibida":"30","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"60000"},{"cantidad_pedida":"20","cantidad_recibida":"10","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"38000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-14","fecha_recibido":"2019-04-26","proveedor":"PR08","total":"55000","iva":"0","paga":"20000","adeuda":"35000","detalle":[{"cantidad_pedida":"8","cantidad_recibida":"5","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10000"},{"cantidad_pedida":"2","cantidad_recibida":"2","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"36000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-15","fecha_recibido":"2019-04-10","proveedor":"PR01","total":"30000","iva":"0","paga":"30000","adeuda":"0","detalle":[{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"30000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-15","fecha_recibido":"2019-04-15","proveedor":"PR02","total":"111600","iva":"0","paga":"82900","adeuda":"28700","detalle":[{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21600"},{"cantidad_pedida":"16","cantidad_recibida":"20","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"90000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-15","fecha_recibido":"2019-04-15","proveedor":"PR06","total":"84000","iva":"0","paga":"70000","adeuda":"14000","detalle":[{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"54000"},{"cantidad_pedida":"15","cantidad_recibida":"15","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"30000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-15","fecha_recibido":"2019-04-15","proveedor":"PR08","total":"80000","iva":"0","paga":"70000","adeuda":"10000","detalle":[{"cantidad_pedida":"20","cantidad_recibida":"20","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"80000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-04-18","fecha_recibido":"2019-04-25","proveedor":"P010","total":"8900","iva":"0","paga":"8900","adeuda":"0","detalle":[{"cantidad_pedida":"4","cantidad_recibida":"2","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4400"},{"cantidad_pedida":"3","cantidad_recibida":"3","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-12","fecha_recibido":"2019-04-10","proveedor":"PR02","total":"242300","iva":"0","paga":"24300","adeuda":"218000","detalle":[{"cantidad_pedida":"27","cantidad_recibida":"27","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24300"},{"cantidad_pedida":"38","cantidad_recibida":"35","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"140000"},{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"78000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-12","fecha_recibido":"2019-04-10","proveedor":"PR04","total":"85000","iva":"0","paga":"85000","adeuda":"0","detalle":[{"cantidad_pedida":"20","cantidad_recibida":"10","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10000"},{"cantidad_pedida":"50","cantidad_recibida":"50","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"75000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-12","fecha_recibido":"2019-04-10","proveedor":"PR07","total":"208200","iva":"0","paga":"100000","adeuda":"108200","detalle":[{"cantidad_pedida":"14","cantidad_recibida":"14","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"109200"},{"cantidad_pedida":"60","cantidad_recibida":"55","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"99000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-23","fecha_recibido":"2019-04-10","proveedor":"P005","total":"246600","iva":"0","paga":"246600","adeuda":"0","detalle":[{"cantidad_pedida":"60","cantidad_recibida":"50","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"225000"},{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21600"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-23","fecha_recibido":"2019-04-10","proveedor":"P006","total":"158400","iva":"0","paga":"158400","adeuda":"0","detalle":[{"cantidad_pedida":"45","cantidad_recibida":"44","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"132000"},{"cantidad_pedida":"22","cantidad_recibida":"12","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"26400"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-23","fecha_recibido":"2019-04-10","proveedor":"P009","total":"147600","iva":"0","paga":"147600","adeuda":"0","detalle":[{"cantidad_pedida":"12","cantidad_recibida":"12","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad_pedida":"20","cantidad_recibida":"18","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39600"},{"cantidad_pedida":"48","cantidad_recibida":"45","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"90000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-23","fecha_recibido":"2019-04-10","proveedor":"PR06","total":"207000","iva":"0","paga":"207000","adeuda":"0","detalle":[{"cantidad_pedida":"30","cantidad_recibida":"30","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"90000"},{"cantidad_pedida":"20","cantidad_recibida":"20","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"90000"},{"cantidad_pedida":"10","cantidad_recibida":"10","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad_pedida":"15","cantidad_recibida":"12","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-31","fecha_recibido":"2019-04-10","proveedor":"PR03","total":"33400","iva":"0","paga":"33400","adeuda":"0","detalle":[{"cantidad_pedida":"7","cantidad_recibida":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"},{"cantidad_pedida":"9","cantidad_recibida":"9","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"}]}');
 SELECT * FROM insertar_compra('{"fecha_compra":"2019-05-31","fecha_recibido":"2019-04-10","proveedor":"PR05","total":"192000","iva":"0","paga":"192000","adeuda":"0","detalle":[{"cantidad_pedida":"21","cantidad_recibida":"20","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"30000"},{"cantidad_pedida":"30","cantidad_recibida":"30","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"105000"},{"cantidad_pedida":"15","cantidad_recibida":"15","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"57000"}]}');

SELECT * FROM insertar_pago_proveedor('P005', 400, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 400, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 400, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 400, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 9000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 9000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 9000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P005', 9000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P006', 500, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('P006', 5100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P006', 5100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P006', 5100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P006', 5100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P008', 25000, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('P008', 8000, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('P009', 100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 100, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 1000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('P009', 10000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 10000, '2019-04-16');
SELECT * FROM insertar_pago_proveedor('P009', 2900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 2900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 2900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 2900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 800, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('P009', 800, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('P009', 900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P009', 900, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('P010', 48000, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('P010', 50000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR01', 4000, '2019-04-17');
SELECT * FROM insertar_pago_proveedor('PR01', 5000, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('PR02', 1000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR02', 10000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR02', 10000, '2019-06-15');
SELECT * FROM insertar_pago_proveedor('PR02', 100000, '2019-06-20');
SELECT * FROM insertar_pago_proveedor('PR02', 13000, '2019-04-25');
SELECT * FROM insertar_pago_proveedor('PR02', 2000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR02', 300, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR02', 40000, '2019-06-13');
SELECT * FROM insertar_pago_proveedor('PR02', 50000, '2019-06-12');
SELECT * FROM insertar_pago_proveedor('PR02', 8000, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR03', 12000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR04', 790, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR05', 200, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('PR05', 2000, '2019-04-17');
SELECT * FROM insertar_pago_proveedor('PR05', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR05', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR05', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR05', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR05', 400, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR05', 800, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR06', 12000, '2019-04-25');
SELECT * FROM insertar_pago_proveedor('PR06', 15000, '2019-04-25');
SELECT * FROM insertar_pago_proveedor('PR06', 16550, '2019-04-27');
SELECT * FROM insertar_pago_proveedor('PR06', 75000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR06', 8000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR07', 10000, '2019-08-01');
SELECT * FROM insertar_pago_proveedor('PR07', 20000, '2019-07-25');
SELECT * FROM insertar_pago_proveedor('PR07', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR07', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR07', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR07', 300, '2019-04-11');
SELECT * FROM insertar_pago_proveedor('PR07', 70000, '2019-07-18');
SELECT * FROM insertar_pago_proveedor('PR07', 8200, '2019-07-11');
SELECT * FROM insertar_pago_proveedor('PR07', 9000, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('PR08', 1000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 1000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 10000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 10000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 16000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 200, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 2000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 20000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 20000, '2019-04-18');
SELECT * FROM insertar_pago_proveedor('PR08', 20000, '2019-04-25');
SELECT * FROM insertar_pago_proveedor('PR08', 3000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 3000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 3000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 3000, '2019-04-12');
SELECT * FROM insertar_pago_proveedor('PR08', 400, '2019-04-18');
SELECT * FROM insertar_pago_proveedor('PR08', 5000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 5000, '2019-04-30');
SELECT * FROM insertar_pago_proveedor('PR08', 50000, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 5602, '2019-04-10');
SELECT * FROM insertar_pago_proveedor('PR08', 700, '2019-04-10');

SELECT * FROM insertar_baja_producto('Daño', '2019-04-01', 6, 5, 900);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 10, 70, 3000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 11, 50, 4500);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 18, 10, 2200);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 3, 20, 3000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 4, 69, 1000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 5, 90, 1200);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 8, 50, 2000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-10', 9, 50, 3000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-11', 6, 29, 900);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-11', 6, 29, 900);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-12', 3, 10, 3000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-12', 3, 2, 3000);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-29', 7, 20, 1500);
SELECT * FROM insertar_baja_producto('Daño', '2019-04-30', 3, 10, 3000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-01', 8, 20, 2000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 14, 90, 4500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 15, 80, 1500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 18, 20, 2200);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 18, 60, 2200);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 2, 91, 1900);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 6, 50, 900);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 7, 10, 1500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-10', 9, 87, 3000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-11', 16, 20, 1500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-11', 16, 56, 1500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-11', 16, 56, 1500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-11', 8, 10, 2000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-11', 8, 10, 2000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-12', 4, 13, 1000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-12', 8, 4, 2000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-29', 10, 22, 3000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-29', 14, 5, 4500);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-30', 10, 80, 3000);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-30', 18, 12, 2200);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-30', 18, 2, 2200);
SELECT * FROM insertar_baja_producto('Descomposición', '2019-04-30', 4, 5, 1000);
SELECT * FROM insertar_baja_producto('Destrucción', '2019-04-01', 4, 60, 1000);
SELECT * FROM insertar_baja_producto('Destrucción', '2019-04-29', 11, 3, 4500);
SELECT * FROM insertar_baja_producto('Destrucción', '2019-04-29', 19, 2, 4000);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-10', 11, 30, 4500);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-10', 13, 96, 7800);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-10', 16, 50, 1500);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-10', 17, 80, 3500);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-10', 5, 20, 1200);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-10', 5, 3, 1200);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-11', 13, 70, 7800);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-11', 13, 70, 7800);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-11', 15, 7, 1500);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-11', 15, 7, 1500);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-11', 8, 45, 2000);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-11', 8, 45, 2000);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-12', 16, 10, 1500);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-12', 5, 50, 1200);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-15', 6, 11, 900);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-26', 5, 5, 1200);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-30', 20, 15, 1800);
SELECT * FROM insertar_baja_producto('Donación', '2019-04-30', 20, 2, 1800);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-10', 16, 50, 1500);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-10', 19, 25, 4000);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-11', 18, 15, 2200);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-11', 18, 15, 2200);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-11', 19, 40, 4000);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-11', 19, 40, 4000);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-12', 13, 10, 7800);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-12', 6, 13, 900);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-29', 20, 8, 1800);
SELECT * FROM insertar_baja_producto('Exclusión', '2019-04-29', 3, 22, 3000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-01', 12, 53, 3800);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-10', 19, 10, 4000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-10', 8, 39, 2000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-11', 9, 21, 3000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-11', 9, 21, 3000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-11', 9, 21, 3000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-11', 9, 21, 3000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-12', 6, 20, 900);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-12', 9, 2, 3000);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-29', 12, 6, 3800);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-29', 16, 15, 1500);
SELECT * FROM insertar_baja_producto('Pérdida', '2019-04-30', 19, 50, 4000);

 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P006","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"7","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"7","cantidad":"2"},{"id_compra":"1","fecha_compra":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"6","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"6","cantidad":"2"},{"id_compra":"1","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"8","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"8","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P006","compra":"11","detalle":[{"id_compra":"11","fecha_compra":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"30","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"30","cantidad":"7"},{"id_compra":"11","fecha_compra":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"30","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"30","cantidad":"6"},{"id_compra":"11","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"25","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"25","cantidad":"5"},{"id_compra":"11","fecha_compra":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","recibido":"19","valor_producto":"4000","total_devuelto":"","comprado-devuelto":"19","cantidad":"5"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P006","compra":"4","detalle":[{"id_compra":"4","fecha_compra":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"9","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"9","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P007","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"6","valor_producto":"900","total_devuelto":"","comprado-devuelto":"6","cantidad":"2"},{"id_compra":"6","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"7","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"7","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P007","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"6","valor_producto":"900","total_devuelto":"2","comprado-devuelto":"4","cantidad":"1"},{"id_compra":"6","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"7","valor_producto":"1500","total_devuelto":"1","comprado-devuelto":"6","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P007","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"3","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"3","cantidad":"2"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","recibido":"3","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"3","cantidad":"2"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"8","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"8","cantidad":"5"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","recibido":"6","valor_producto":"4000","total_devuelto":"","comprado-devuelto":"6","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P007","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"7","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"7","cantidad":"2"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"8","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"8","cantidad":"1"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"10","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"10","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P008","compra":"9","detalle":[{"id_compra":"9","fecha_compra":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","recibido":"48","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"48","cantidad":"8"},{"id_compra":"9","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"27","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"27","cantidad":"7"},{"id_compra":"9","fecha_compra":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"40","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"40","cantidad":"6"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P009","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"12","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"12","cantidad":"3"},{"id_compra":"1","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"14","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"14","cantidad":"3"},{"id_compra":"1","fecha_compra":"2019-04-10","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","recibido":"19","valor_producto":"1800","total_devuelto":"","comprado-devuelto":"19","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P010","compra":"5","detalle":[{"id_compra":"5","fecha_compra":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","recibido":"11","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"11","cantidad":"3"},{"id_compra":"5","fecha_compra":"2019-04-10","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","recibido":"22","valor_producto":"3500","total_devuelto":"","comprado-devuelto":"22","cantidad":"11"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"P010","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"13","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"13","cantidad":"4"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"3","valor_producto":"900","total_devuelto":"","comprado-devuelto":"3","cantidad":"1"},{"id_compra":"7","fecha_compra":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","recibido":"15","valor_producto":"4000","total_devuelto":"","comprado-devuelto":"15","cantidad":"9"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR02","compra":"3","detalle":[{"id_compra":"3","fecha_compra":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"10","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"10","cantidad":"3"},{"id_compra":"3","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"8","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"8","cantidad":"4"},{"id_compra":"3","fecha_compra":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"12","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"12","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR02","compra":"3","detalle":[{"id_compra":"3","fecha_compra":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"36","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"36","cantidad":"11"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR03","compra":"9","detalle":[{"id_compra":"9","fecha_compra":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"4","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"4","cantidad":"1"},{"id_compra":"9","fecha_compra":"2019-04-10","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","recibido":"3","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"3","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR03","compra":"9","detalle":[{"id_compra":"9","fecha_compra":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"5","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"5","cantidad":"1"},{"id_compra":"9","fecha_compra":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"5","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"5","cantidad":"1"},{"id_compra":"9","fecha_compra":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"6","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"6","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR04","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-10","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","recibido":"6","valor_producto":"1900","total_devuelto":"","comprado-devuelto":"6","cantidad":"3"},{"id_compra":"2","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"6","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"6","cantidad":"3"},{"id_compra":"2","fecha_compra":"2019-04-10","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","recibido":"5","valor_producto":"3500","total_devuelto":"","comprado-devuelto":"5","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR04","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"9","valor_producto":"4500","total_devuelto":"1","comprado-devuelto":"8","cantidad":"5"},{"id_compra":"6","fecha_compra":"2019-04-10","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","recibido":"5","valor_producto":"3500","total_devuelto":"","comprado-devuelto":"5","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR04","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","recibido":"7","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"7","cantidad":"6"},{"id_compra":"6","fecha_compra":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"9","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"9","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR05","compra":"4","detalle":[{"id_compra":"4","fecha_compra":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"15","valor_producto":"900","total_devuelto":"","comprado-devuelto":"15","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR05","compra":"5","detalle":[{"id_compra":"5","fecha_compra":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","recibido":"7","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"7","cantidad":"2"},{"id_compra":"5","fecha_compra":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"10","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"10","cantidad":"4"},{"id_compra":"5","fecha_compra":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"9","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"9","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR06","compra":"5","detalle":[{"id_compra":"5","fecha_compra":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","recibido":"10","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"10","cantidad":"4"},{"id_compra":"5","fecha_compra":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"8","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"8","cantidad":"2"},{"id_compra":"5","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"7","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"7","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR06","compra":"8","detalle":[{"id_compra":"8","fecha_compra":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"69","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"69","cantidad":"13"},{"id_compra":"8","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"50","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"50","cantidad":"11"},{"id_compra":"8","fecha_compra":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","recibido":"33","valor_producto":"4000","total_devuelto":"","comprado-devuelto":"33","cantidad":"11"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR07","compra":"10","detalle":[{"id_compra":"10","fecha_compra":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"11","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"11","cantidad":"2"},{"id_compra":"10","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"30","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"30","cantidad":"10"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR07","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"5","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"5","cantidad":"2"},{"id_compra":"6","fecha_compra":"2019-04-10","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","recibido":"8","valor_producto":"3500","total_devuelto":"","comprado-devuelto":"8","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR08","compra":"10","detalle":[{"id_compra":"10","fecha_compra":"2019-04-10","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","recibido":"20","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"20","cantidad":"8"},{"id_compra":"10","fecha_compra":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"26","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"26","cantidad":"6"},{"id_compra":"10","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"40","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"40","cantidad":"14"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-10","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","recibido":"34","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"34","cantidad":"22"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"6","valor_producto":"900","total_devuelto":"","comprado-devuelto":"6","cantidad":"1"},{"id_compra":"2","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"4","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"4","cantidad":"2"},{"id_compra":"2","fecha_compra":"2019-04-10","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","recibido":"19","valor_producto":"3500","total_devuelto":"","comprado-devuelto":"19","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-10","proveedor":"PR08","compra":"8","detalle":[{"id_compra":"8","fecha_compra":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","recibido":"36","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"36","cantidad":"4"},{"id_compra":"8","fecha_compra":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"22","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"22","cantidad":"14"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P005","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"21","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"21","cantidad":"1"},{"id_compra":"6","fecha_compra":"2019-04-11","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"12","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"12","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P005","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"21","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"21","cantidad":"1"},{"id_compra":"6","fecha_compra":"2019-04-11","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"12","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"12","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P006","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-11","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"2","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"2","cantidad":"1"},{"id_compra":"7","fecha_compra":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"13","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"13","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P006","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-11","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"2","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"2","cantidad":"1"},{"id_compra":"7","fecha_compra":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"13","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"13","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P006","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-11","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"1","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"1","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P006","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-11","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"1","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"1","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P007","compra":"8","detalle":[{"id_compra":"8","fecha_compra":"2019-04-11","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"32","valor_producto":"900","total_devuelto":"","comprado-devuelto":"32","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P007","compra":"8","detalle":[{"id_compra":"8","fecha_compra":"2019-04-11","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"32","valor_producto":"900","total_devuelto":"","comprado-devuelto":"32","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P009","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"5","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"5","cantidad":"2"},{"id_compra":"1","fecha_compra":"2019-04-11","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"17","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"17","cantidad":"17"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P009","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"5","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"5","cantidad":"2"},{"id_compra":"1","fecha_compra":"2019-04-11","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"17","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"17","cantidad":"17"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P010","compra":"10","detalle":[{"id_compra":"10","fecha_compra":"2019-04-11","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","recibido":"64","valor_producto":"1800","total_devuelto":"","comprado-devuelto":"64","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"P010","compra":"10","detalle":[{"id_compra":"10","fecha_compra":"2019-04-11","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","recibido":"64","valor_producto":"1800","total_devuelto":"","comprado-devuelto":"64","cantidad":"4"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR05","compra":"3","detalle":[{"id_compra":"3","fecha_compra":"2019-04-11","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"7","valor_producto":"900","total_devuelto":"","comprado-devuelto":"7","cantidad":"1"},{"id_compra":"3","fecha_compra":"2019-04-11","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"4","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"4","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR05","compra":"3","detalle":[{"id_compra":"3","fecha_compra":"2019-04-11","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"7","valor_producto":"900","total_devuelto":"","comprado-devuelto":"7","cantidad":"1"},{"id_compra":"3","fecha_compra":"2019-04-11","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"4","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"4","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR06","compra":"4","detalle":[{"id_compra":"4","fecha_compra":"2019-04-11","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"15","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"15","cantidad":"2"},{"id_compra":"4","fecha_compra":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"80","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"80","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR06","compra":"4","detalle":[{"id_compra":"4","fecha_compra":"2019-04-11","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"15","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"15","cantidad":"2"},{"id_compra":"4","fecha_compra":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"80","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"80","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"11","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"11","cantidad":"8"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"11","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"11","cantidad":"8"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","recibido":"40","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"40","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-11","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","recibido":"40","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"40","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"P005","compra":"9","detalle":[{"id_compra":"9","fecha_compra":"2019-04-11","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"20","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"20","cantidad":"5"},{"id_compra":"9","fecha_compra":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"30","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"30","cantidad":"7"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"P008","compra":"10","detalle":[{"id_compra":"10","fecha_compra":"2019-04-11","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"10","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"10","cantidad":"5"},{"id_compra":"10","fecha_compra":"2019-04-11","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","recibido":"20","valor_producto":"4000","total_devuelto":"","comprado-devuelto":"20","cantidad":"10"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"P009","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"8","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"8","cantidad":"3"},{"id_compra":"1","fecha_compra":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"5","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"5","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"P010","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-04-18","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","recibido":"3","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"3","cantidad":"1"},{"id_compra":"7","fecha_compra":"2019-04-18","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"2","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"2","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"P010","compra":"8","detalle":[{"id_compra":"8","fecha_compra":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","recibido":"30","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"30","cantidad":"10"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"PR01","compra":"3","detalle":[{"id_compra":"3","fecha_compra":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"5","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"5","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"PR01","compra":"4","detalle":[{"id_compra":"4","fecha_compra":"2019-04-09","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"1","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"1","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"PR05","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"1","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"1","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"PR07","compra":"5","detalle":[{"id_compra":"5","fecha_compra":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"5","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"5","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-12","proveedor":"PR08","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"3","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"3","cantidad":"1"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-17","proveedor":"PR01","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-15","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","recibido":"10","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"10","cantidad":"3"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-05-14","proveedor":"PR04","compra":"8","detalle":[{"id_compra":"8","fecha_compra":"2019-05-12","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","recibido":"50","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"50","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-05-16","proveedor":"PR02","compra":"9","detalle":[{"id_compra":"9","fecha_compra":"2019-05-12","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","recibido":"27","valor_producto":"900","total_devuelto":"","comprado-devuelto":"27","cantidad":"7"},{"id_compra":"9","fecha_compra":"2019-05-12","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","recibido":"35","valor_producto":"4000","total_devuelto":"","comprado-devuelto":"35","cantidad":"5"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-05-23","proveedor":"PR07","compra":"10","detalle":[{"id_compra":"10","fecha_compra":"2019-05-12","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","recibido":"14","valor_producto":"7800","total_devuelto":"","comprado-devuelto":"14","cantidad":"2"},{"id_compra":"10","fecha_compra":"2019-05-12","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","recibido":"55","valor_producto":"1800","total_devuelto":"","comprado-devuelto":"55","cantidad":"13"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-05-24","proveedor":"P005","compra":"3","detalle":[{"id_compra":"3","fecha_compra":"2019-05-23","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","recibido":"50","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"50","cantidad":"15"},{"id_compra":"3","fecha_compra":"2019-05-23","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","recibido":"12","valor_producto":"1800","total_devuelto":"","comprado-devuelto":"12","cantidad":"6"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-05-24","proveedor":"P006","compra":"5","detalle":[{"id_compra":"5","fecha_compra":"2019-05-23","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","recibido":"44","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"44","cantidad":"14"},{"id_compra":"5","fecha_compra":"2019-05-23","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"12","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"12","cantidad":"5"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-06-01","proveedor":"P009","compra":"2","detalle":[{"id_compra":"2","fecha_compra":"2019-05-23","producto":"1","descripcion_producto":"Leche Colanta Bolsa x 1000 cc","recibido":"45","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"45","cantidad":"10"},{"id_compra":"2","fecha_compra":"2019-05-23","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"12","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"12","cantidad":"2"},{"id_compra":"2","fecha_compra":"2019-05-23","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"18","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"18","cantidad":"6"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-06-02","proveedor":"PR05","compra":"7","detalle":[{"id_compra":"7","fecha_compra":"2019-05-31","producto":"12","descripcion_producto":"Mantequilla Colanta Unidad","recibido":"15","valor_producto":"3800","total_devuelto":"","comprado-devuelto":"15","cantidad":"2"},{"id_compra":"7","fecha_compra":"2019-05-31","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","recibido":"20","valor_producto":"1500","total_devuelto":"","comprado-devuelto":"20","cantidad":"2"},{"id_compra":"7","fecha_compra":"2019-05-31","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","recibido":"30","valor_producto":"3500","total_devuelto":"","comprado-devuelto":"30","cantidad":"7"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-06-02","proveedor":"PR06","compra":"4","detalle":[{"id_compra":"4","fecha_compra":"2019-05-23","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","recibido":"30","valor_producto":"3000","total_devuelto":"","comprado-devuelto":"30","cantidad":"30"},{"id_compra":"4","fecha_compra":"2019-05-23","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","recibido":"12","valor_producto":"1000","total_devuelto":"","comprado-devuelto":"12","cantidad":"2"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-06-04","proveedor":"PR03","compra":"6","detalle":[{"id_compra":"6","fecha_compra":"2019-05-31","producto":"1","descripcion_producto":"Leche Colanta Bolsa x 1000 cc","recibido":"9","valor_producto":"2000","total_devuelto":"","comprado-devuelto":"9","cantidad":"9"},{"id_compra":"6","fecha_compra":"2019-05-31","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","recibido":"7","valor_producto":"2200","total_devuelto":"","comprado-devuelto":"7","cantidad":"7"}]}');
 SELECT * FROM insertar_devolucion_compra('{"fecha":"2019-04-09","proveedor":"P009","compra":"1","detalle":[{"id_compra":"1","fecha_compra":"2019-04-02","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","recibido":"50","valor_producto":"4500","total_devuelto":"","comprado-devuelto":"50","cantidad":"9"}]}');

SELECT * FROM insertar_venta('{"fecha":"2019-04-01","cliente":"CL002","vendedor":"010","total":"13500","iva":"0","paga":"13400","adeuda":"100","detalle":[{"cantidad":"2","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"3","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-01","cliente":"CL003","vendedor":"010","total":"23000","iva":"0","paga":"23000","adeuda":"0","detalle":[{"cantidad":"4","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"},{"cantidad":"5","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-03","cliente":"CL004","vendedor":"010","total":"20100","iva":"0","paga":"20100","adeuda":"0","detalle":[{"cantidad":"2","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"},{"cantidad":"3","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-03","cliente":"CL011","vendedor":"010","total":"10800","iva":"0","paga":"10800","adeuda":"0","detalle":[{"cantidad":"4","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7200"},{"cantidad":"3","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-03","cliente":"CL016","vendedor":"010","total":"20700","iva":"0","paga":"20000","adeuda":"700","detalle":[{"cantidad":"5","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"3","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2700"},{"cantidad":"2","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL004","vendedor":"001","total":"7900","iva":"0","paga":"7500","adeuda":"400","detalle":[{"cantidad":"1","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1500"},{"cantidad":"1","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1900"},{"cantidad":"1","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL007","vendedor":"001","total":"20900","iva":"0","paga":"15000","adeuda":"5900","detalle":[{"cantidad":"3","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1500"},{"cantidad":"2","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3800"},{"cantidad":"2","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL007","vendedor":"001","total":"29700","iva":"0","paga":"20000","adeuda":"9700","detalle":[{"cantidad":"2","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1900"},{"cantidad":"1","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"},{"cantidad":"4","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad":"5","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"1","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3800"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL010","vendedor":"001","total":"16000","iva":"0","paga":"15800","adeuda":"200","detalle":[{"cantidad":"2","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4000"},{"cantidad":"2","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"1","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL011","vendedor":"001","total":"17100","iva":"0","paga":"15000","adeuda":"2100","detalle":[{"cantidad":"3","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"2","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL012","vendedor":"010","total":"23100","iva":"0","paga":"23000","adeuda":"100","detalle":[{"cantidad":"2","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"},{"cantidad":"3","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"},{"cantidad":"2","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL013","vendedor":"010","total":"23900","iva":"0","paga":"23000","adeuda":"900","detalle":[{"cantidad":"3","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5700"},{"cantidad":"4","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15200"},{"cantidad":"2","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-07","cliente":"CL015","vendedor":"010","total":"19600","iva":"0","paga":"19000","adeuda":"600","detalle":[{"cantidad":"4","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"},{"cantidad":"2","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"},{"cantidad":"5","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5000"},{"cantidad":"4","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL001","vendedor":"001","total":"9600","iva":"0","paga":"5000","adeuda":"4600","detalle":[{"cantidad":"2","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3600"},{"cantidad":"3","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL001","vendedor":"010","total":"63700","iva":"0","paga":"63700","adeuda":"0","detalle":[{"cantidad":"5","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10000"},{"cantidad":"6","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13200"},{"cantidad":"9","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL002","vendedor":"001","total":"105700","iva":"0","paga":"105700","adeuda":"0","detalle":[{"cantidad":"5","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"20000"},{"cantidad":"9","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"70200"},{"cantidad":"5","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5000"},{"cantidad":"7","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL002","vendedor":"001","total":"71100","iva":"0","paga":"71100","adeuda":"0","detalle":[{"cantidad":"8","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad":"6","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"7","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"9","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8100"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL003","vendedor":"001","total":"59600","iva":"0","paga":"59600","adeuda":"0","detalle":[{"cantidad":"8","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17600"},{"cantidad":"6","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad":"7","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"9","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL003","vendedor":"010","total":"53100","iva":"0","paga":"53100","adeuda":"0","detalle":[{"cantidad":"5","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"6","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11400"},{"cantidad":"9","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"34200"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL004","vendedor":"001","total":"15000","iva":"0","paga":"5000","adeuda":"10000","detalle":[{"cantidad":"2","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad":"3","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL004","vendedor":"001","total":"4500","iva":"0","paga":"4500","adeuda":"0","detalle":[{"cantidad":"3","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL004","vendedor":"001","total":"56600","iva":"0","paga":"56600","adeuda":"0","detalle":[{"cantidad":"8","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"},{"cantidad":"6","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"7","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12600"},{"cantidad":"9","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL004","vendedor":"010","total":"48400","iva":"0","paga":"48400","adeuda":"0","detalle":[{"cantidad":"5","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad":"6","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL005","vendedor":"001","total":"6000","iva":"0","paga":"6000","adeuda":"0","detalle":[{"cantidad":"2","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL006","vendedor":"001","total":"18800","iva":"0","paga":"15000","adeuda":"3800","detalle":[{"cantidad":"2","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3800"},{"cantidad":"3","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad":"2","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL006","vendedor":"010","total":"46100","iva":"0","paga":"46100","adeuda":"0","detalle":[{"cantidad":"5","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"20000"},{"cantidad":"6","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"9","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17100"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL007","vendedor":"001","total":"55900","iva":"0","paga":"55900","adeuda":"0","detalle":[{"cantidad":"6","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"9","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL007","vendedor":"010","total":"24000","iva":"0","paga":"24000","adeuda":"0","detalle":[{"cantidad":"3","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5400"},{"cantidad":"4","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad":"2","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"3","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL007","vendedor":"010","total":"45500","iva":"0","paga":"45500","adeuda":"0","detalle":[{"cantidad":"5","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5000"},{"cantidad":"6","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"7","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL008","vendedor":"001","total":"25500","iva":"0","paga":"25500","adeuda":"0","detalle":[{"cantidad":"5","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"22500"},{"cantidad":"2","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL008","vendedor":"010","total":"63700","iva":"0","paga":"63700","adeuda":"0","detalle":[{"cantidad":"5","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10000"},{"cantidad":"6","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13200"},{"cantidad":"9","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL009","vendedor":"001","total":"58900","iva":"0","paga":"58900","adeuda":"0","detalle":[{"cantidad":"5","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"9","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"5","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL009","vendedor":"010","total":"68300","iva":"0","paga":"68300","adeuda":"0","detalle":[{"cantidad":"5","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11000"},{"cantidad":"6","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"46800"},{"cantidad":"7","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL010","vendedor":"001","total":"63600","iva":"0","paga":"63600","adeuda":"0","detalle":[{"cantidad":"6","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"7","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"54600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL010","vendedor":"001","total":"69500","iva":"0","paga":"69500","adeuda":"0","detalle":[{"cantidad":"6","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"9","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"7","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"},{"cantidad":"5","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL010","vendedor":"010","total":"38400","iva":"0","paga":"38400","adeuda":"0","detalle":[{"cantidad":"5","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"22500"},{"cantidad":"6","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5400"},{"cantidad":"7","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL011","vendedor":"001","total":"113100","iva":"0","paga":"113100","adeuda":"0","detalle":[{"cantidad":"5","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17500"},{"cantidad":"9","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"7","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"5","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11000"},{"cantidad":"7","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"54600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL011","vendedor":"010","total":"60300","iva":"0","paga":"60300","adeuda":"0","detalle":[{"cantidad":"5","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"20000"},{"cantidad":"6","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"7","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13300"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL012","vendedor":"001","total":"2700","iva":"0","paga":"2700","adeuda":"0","detalle":[{"cantidad":"3","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2700"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL013","vendedor":"001","total":"24000","iva":"0","paga":"24000","adeuda":"0","detalle":[{"cantidad":"4","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4800"},{"cantidad":"2","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3600"},{"cantidad":"2","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL014","vendedor":"001","total":"133300","iva":"0","paga":"133300","adeuda":"0","detalle":[{"cantidad":"8","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"32000"},{"cantidad":"6","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"46800"},{"cantidad":"7","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"14000"},{"cantidad":"9","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL015","vendedor":"001","total":"25200","iva":"0","paga":"20000","adeuda":"5200","detalle":[{"cantidad":"2","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"1800"},{"cantidad":"3","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"23400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL015","vendedor":"010","total":"79500","iva":"0","paga":"79500","adeuda":"0","detalle":[{"cantidad":"5","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"},{"cantidad":"6","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"9","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL016","vendedor":"001","total":"16000","iva":"0","paga":"15000","adeuda":"1000","detalle":[{"cantidad":"4","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"},{"cantidad":"2","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"},{"cantidad":"5","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"5000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL016","vendedor":"001","total":"89100","iva":"0","paga":"89100","adeuda":"0","detalle":[{"cantidad":"8","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9600"},{"cantidad":"6","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"7","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"9","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-10","cliente":"CL016","vendedor":"010","total":"33500","iva":"0","paga":"33500","adeuda":"0","detalle":[{"cantidad":"2","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad":"3","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad":"4","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"6000"},{"cantidad":"5","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"2","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL002","vendedor":"001","total":"77000","iva":"0","paga":"50000","adeuda":"27000","detalle":[{"cantidad":"5","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"10","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad":"7","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"14000"},{"cantidad":"7","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL002","vendedor":"001","total":"77000","iva":"0","paga":"50000","adeuda":"27000","detalle":[{"cantidad":"5","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"10","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad":"7","producto":"1-Leche Colanta Bolsa x 1000 cc","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"14000"},{"cantidad":"7","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL004","vendedor":"001","total":"50500","iva":"0","paga":"13500","adeuda":"37000","detalle":[{"cantidad":"8","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad":"7","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7000"},{"cantidad":"7","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL004","vendedor":"001","total":"50500","iva":"0","paga":"13500","adeuda":"37000","detalle":[{"cantidad":"8","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad":"7","producto":"4-Lentejas Bolsa x 500 gramos","valor":"1000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7000"},{"cantidad":"7","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL007","vendedor":"001","total":"39900","iva":"0","paga":"39000","adeuda":"900","detalle":[{"cantidad":"5","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"6","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad":"7","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL007","vendedor":"001","total":"39900","iva":"0","paga":"39000","adeuda":"900","detalle":[{"cantidad":"5","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"},{"cantidad":"6","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad":"7","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL007","vendedor":"001","total":"65000","iva":"0","paga":"24250","adeuda":"40750","detalle":[{"cantidad":"7","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"},{"cantidad":"6","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"5","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"19000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL007","vendedor":"001","total":"65000","iva":"0","paga":"24250","adeuda":"40750","detalle":[{"cantidad":"7","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"},{"cantidad":"6","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"5","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"19000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL009","vendedor":"001","total":"42900","iva":"0","paga":"12900","adeuda":"30000","detalle":[{"cantidad":"9","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"6","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"7","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL009","vendedor":"001","total":"42900","iva":"0","paga":"12900","adeuda":"30000","detalle":[{"cantidad":"9","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"6","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"7","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL009","vendedor":"001","total":"55500","iva":"0","paga":"45000","adeuda":"10500","detalle":[{"cantidad":"7","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"6","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"5","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL009","vendedor":"001","total":"55500","iva":"0","paga":"45000","adeuda":"10500","detalle":[{"cantidad":"7","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"21000"},{"cantidad":"6","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"5","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL010","vendedor":"001","total":"47500","iva":"0","paga":"10000","adeuda":"37500","detalle":[{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"},{"cantidad":"10","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad":"9","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17100"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL010","vendedor":"001","total":"47500","iva":"0","paga":"10000","adeuda":"37500","detalle":[{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"},{"cantidad":"10","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad":"9","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17100"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL010","vendedor":"001","total":"49600","iva":"0","paga":"49000","adeuda":"600","detalle":[{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"},{"cantidad":"9","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"8","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7200"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL010","vendedor":"001","total":"49600","iva":"0","paga":"49000","adeuda":"600","detalle":[{"cantidad":"7","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15400"},{"cantidad":"9","producto":"9-Maracuya Paquete x 3 Unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"8","producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7200"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL011","vendedor":"001","total":"45500","iva":"0","paga":"37500","adeuda":"8000","detalle":[{"cantidad":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad":"9","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"10","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"20000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL011","vendedor":"001","total":"45500","iva":"0","paga":"37500","adeuda":"8000","detalle":[{"cantidad":"8","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"12000"},{"cantidad":"9","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"},{"cantidad":"10","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"20000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL014","vendedor":"001","total":"68000","iva":"0","paga":"43500","adeuda":"24500","detalle":[{"cantidad":"10","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad":"5","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"},{"cantidad":"7","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"14000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-11","cliente":"CL014","vendedor":"001","total":"68000","iva":"0","paga":"43500","adeuda":"24500","detalle":[{"cantidad":"10","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad":"5","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"39000"},{"cantidad":"7","producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"14000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-15","cliente":"CL009","vendedor":"001","total":"64000","iva":"0","paga":"64000","adeuda":"0","detalle":[{"cantidad":"5","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"9","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"7","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-17","cliente":"CL011","vendedor":"001","total":"10500","iva":"0","paga":"8000","adeuda":"2500","detalle":[{"cantidad":"1","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"2200"},{"cantidad":"1","producto":"12-Mantequilla Colanta Unidad","valor":"3800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3800"},{"cantidad":"1","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"4500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-17","cliente":"CL012","vendedor":"001","total":"10800","iva":"0","paga":"10000","adeuda":"800","detalle":[{"cantidad":"1","producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7800"},{"cantidad":"1","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"3000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-25","cliente":"CL001","vendedor":"001","total":"88500","iva":"0","paga":"88000","adeuda":"500","detalle":[{"cantidad":"6","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"},{"cantidad":"9","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"40500"},{"cantidad":"5","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"11000"},{"cantidad":"7","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-29","cliente":"CL012","vendedor":"001","total":"82000","iva":"0","paga":"82000","adeuda":"0","detalle":[{"cantidad":"8","producto":"17-Mantequilla Don Oleo Unidad","valor":"3500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"28000"},{"cantidad":"10","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"45000"},{"cantidad":"6","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-05-04","cliente":"CL001","vendedor":"001","total":"48200","iva":"0","paga":"48200","adeuda":"0","detalle":[{"cantidad":"5","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15000"},{"cantidad":"6","producto":"3-Mandarinas Bolsa x 12 unidades","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"8","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15200"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-05-04","cliente":"CL008","vendedor":"001","total":"36600","iva":"0","paga":"36600","adeuda":"0","detalle":[{"cantidad":"10","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"19000"},{"cantidad":"8","producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"17600"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-05-04","cliente":"CL010","vendedor":"001","total":"92700","iva":"0","paga":"92000","adeuda":"700","detalle":[{"cantidad":"10","producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"18000"},{"cantidad":"8","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"36000"},{"cantidad":"7","producto":"11-Cafe Monumental Bolsa x 500 gramos","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"31500"},{"cantidad":"6","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"7200"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-05-04","cliente":"CL013","vendedor":"001","total":"28700","iva":"0","paga":"28700","adeuda":"0","detalle":[{"cantidad":"8","producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"15200"},{"cantidad":"9","producto":"16-Frijol del Costal Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"13500"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-05-04","cliente":"CL015","vendedor":"001","total":"45900","iva":"0","paga":"45900","adeuda":"0","detalle":[{"cantidad":"7","producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"10500"},{"cantidad":"6","producto":"14-Manzanas Paquete x 3 Unidades","valor":"4500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"27000"},{"cantidad":"7","producto":"5-Arroz Do\u00f1a Pepa Bolsa x 500 gramos","valor":"1200","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"8400"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-05-04","cliente":"CL016","vendedor":"001","total":"69000","iva":"0","paga":"60000","adeuda":"9000","detalle":[{"cantidad":"8","producto":"10-Cereal Madagascar Bolsa x 500 gramos","valor":"3000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"24000"},{"cantidad":"9","producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"36000"},{"cantidad":"6","producto":"15-Arroz Buen Dia Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":"0","subtotal":"9000"}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL001","vendedor":"001","total":"1500","iva":"0","paga":"0","adeuda":"1500","detalle":[{"cantidad":1,"producto":"15-Arroz Diana Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":0,"subtotal":1500}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL003","vendedor":"001","total":"1900","iva":"0","paga":"0","adeuda":"1900","detalle":[{"cantidad":1,"producto":"2-Lecha entera Celema Bolsa x 1000 cc","valor":"1900","iva_porcentaje":"0.0","iva_valor":0,"subtotal":1900}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL004","vendedor":"001","total":"1800","iva":"0","paga":"0","adeuda":"1800","detalle":[{"cantidad":1,"producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":0,"subtotal":1800}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL006","vendedor":"001","total":"4000","iva":"0","paga":"0","adeuda":"4000","detalle":[{"cantidad":1,"producto":"19-Jabon en polvo Josefina Bolsa x 1 kg","valor":"4000","iva_porcentaje":"0.0","iva_valor":0,"subtotal":4000}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL008","vendedor":"001","total":"1500","iva":"0","paga":"0","adeuda":"1500","detalle":[{"cantidad":1,"producto":"7-Lechuga Bolsa x 500 gramos","valor":"1500","iva_porcentaje":"0.0","iva_valor":0,"subtotal":1500}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL009","vendedor":"001","total":"2000","iva":"0","paga":"0","adeuda":"2000","detalle":[{"cantidad":1,"producto":"8-Kiwi Paquete x 3 Unidades","valor":"2000","iva_porcentaje":"0.0","iva_valor":0,"subtotal":2000}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL010","vendedor":"001","total":"1800","iva":"0","paga":"0","adeuda":"1800","detalle":[{"cantidad":1,"producto":"20-Crema dental Colgate Unidad","valor":"1800","iva_porcentaje":"0.0","iva_valor":0,"subtotal":1800}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL011","vendedor":"001","total":"10000","iva":"0","paga":"0","adeuda":"10000","detalle":[{"cantidad":1,"producto":"13-Jabon Ariel Bolsa x 1 kg","valor":"7800","iva_porcentaje":"0.0","iva_valor":0,"subtotal":7800},{"cantidad":1,"producto":"18-Crema de leche Colanta Bolsa x 500 gramos","valor":"2200","iva_porcentaje":"0.0","iva_valor":0,"subtotal":2200}]}');
SELECT * FROM insertar_venta('{"fecha":"2019-04-16","cliente":"CL015","vendedor":"001","total":"900","iva":"0","paga":"0","adeuda":"900","detalle":[{"cantidad":1,"producto":"6-Ma\u00edz trillado Bolsa x 1 kg","valor":"900","iva_porcentaje":"0.0","iva_valor":0,"subtotal":900}]}');

SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-04","cliente":"CL011","venta":"5","detalle":[{"id_venta":"5","fecha_venta":"2019-04-03","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"4","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"4","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-07","cliente":"CL002","venta":"12","detalle":[{"id_venta":"12","fecha_venta":"2019-04-01","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"2","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"2","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-07","cliente":"CL015","venta":"10","detalle":[{"id_venta":"10","fecha_venta":"2019-04-07","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"5","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"5","cantidad":"4"},{"id_venta":"10","fecha_venta":"2019-04-07","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"4","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"4","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-07","cliente":"CL016","venta":"6","detalle":[{"id_venta":"6","fecha_venta":"2019-04-03","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","vendido":"3","valor_producto":"900","total_devuelto":"","vendido-devuelto":"3","cantidad":"2"},{"id_venta":"6","fecha_venta":"2019-04-03","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"5","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-08","cliente":"CL002","venta":"12","detalle":[{"id_venta":"12","fecha_venta":"2019-04-01","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"3","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"3","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-09","cliente":"CL011","venta":"5","detalle":[{"id_venta":"5","fecha_venta":"2019-04-03","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"3","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"3","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL001","venta":"10","detalle":[{"id_venta":"10","fecha_venta":"2019-04-25","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","vendido":"9","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"10","fecha_venta":"2019-04-25","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"6","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-25","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"5","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"},{"id_venta":"10","fecha_venta":"2019-04-25","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"7","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"7","cantidad":"5"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL001","venta":"7","detalle":[{"id_venta":"7","fecha_venta":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"5","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"5","cantidad":"3"},{"id_venta":"7","fecha_venta":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"9","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"7","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"6","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"6","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL002","venta":"10","detalle":[{"id_venta":"10","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"7","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","vendido":"9","valor_producto":"900","total_devuelto":"","vendido-devuelto":"9","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"8","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"8","cantidad":"3"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","vendido":"6","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL002","venta":"10","detalle":[{"id_venta":"10","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"7","valor_producto":"3000","total_devuelto":"1","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","vendido":"9","valor_producto":"900","total_devuelto":"1","vendido-devuelto":"8","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"8","valor_producto":"3000","total_devuelto":"3","vendido-devuelto":"5","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","vendido":"6","valor_producto":"3000","total_devuelto":"1","vendido-devuelto":"5","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL002","venta":"5","detalle":[{"id_venta":"5","fecha_venta":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"5","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"},{"id_venta":"5","fecha_venta":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"7","cantidad":"2"},{"id_venta":"5","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"9","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"9","cantidad":"4"},{"id_venta":"5","fecha_venta":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"5","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"5","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL003","venta":"7","detalle":[{"id_venta":"7","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"7","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"},{"id_venta":"7","fecha_venta":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"9","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"},{"id_venta":"7","fecha_venta":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"6","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"6","cantidad":"3"},{"id_venta":"7","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"8","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"8","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL003","venta":"9","detalle":[{"id_venta":"9","fecha_venta":"2019-04-10","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"6","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"9","fecha_venta":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"5","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL004","venta":"4","detalle":[{"id_venta":"4","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"6","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"6","cantidad":"2"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"5","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"7","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"7","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL004","venta":"7","detalle":[{"id_venta":"7","fecha_venta":"2019-04-03","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"2","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"2","cantidad":"1"},{"id_venta":"7","fecha_venta":"2019-04-03","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"3","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"3","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL004","venta":"9","detalle":[{"id_venta":"9","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"9","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"},{"id_venta":"9","fecha_venta":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"8","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"8","cantidad":"2"},{"id_venta":"9","fecha_venta":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"6","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"6","cantidad":"2"},{"id_venta":"9","fecha_venta":"2019-04-10","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"7","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"7","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL006","venta":"8","detalle":[{"id_venta":"8","fecha_venta":"2019-04-10","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"9","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"9","cantidad":"4"},{"id_venta":"8","fecha_venta":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"6","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"6","cantidad":"4"},{"id_venta":"8","fecha_venta":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"5","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL007","venta":"1","detalle":[{"id_venta":"1","fecha_venta":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"6","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"6","cantidad":"3"},{"id_venta":"1","fecha_venta":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"},{"id_venta":"1","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"7","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL007","venta":"1","detalle":[{"id_venta":"1","fecha_venta":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"3","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"3","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL007","venta":"1","detalle":[{"id_venta":"1","fecha_venta":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"5","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"},{"id_venta":"1","fecha_venta":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"7","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"7","cantidad":"4"},{"id_venta":"1","fecha_venta":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"6","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL007","venta":"4","detalle":[{"id_venta":"4","fecha_venta":"2019-04-10","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"3","valor_producto":"1800","total_devuelto":"1","vendido-devuelto":"2","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL007","venta":"4","detalle":[{"id_venta":"4","fecha_venta":"2019-04-10","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"3","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"3","cantidad":"1"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"4","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"4","cantidad":"2"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"3","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"3","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL008","venta":"6","detalle":[{"id_venta":"6","fecha_venta":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"9","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"6","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"6","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL009","venta":"4","detalle":[{"id_venta":"4","fecha_venta":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"5","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"9","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"7","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"4","fecha_venta":"2019-04-10","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"5","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL009","venta":"5","detalle":[{"id_venta":"5","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"6","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"5","fecha_venta":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL010","venta":"2","detalle":[{"id_venta":"2","fecha_venta":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","vendido":"6","valor_producto":"900","total_devuelto":"","vendido-devuelto":"6","cantidad":"2"},{"id_venta":"2","fecha_venta":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL010","venta":"2","detalle":[{"id_venta":"2","fecha_venta":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"5","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"5","cantidad":"4"},{"id_venta":"2","fecha_venta":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"6","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"6","cantidad":"3"},{"id_venta":"2","fecha_venta":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"2","fecha_venta":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"7","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL011","venta":"3","detalle":[{"id_venta":"3","fecha_venta":"2019-04-10","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","vendido":"3","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"3","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL011","venta":"3","detalle":[{"id_venta":"3","fecha_venta":"2019-04-10","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"7","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"7","cantidad":"6"},{"id_venta":"3","fecha_venta":"2019-04-10","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","vendido":"6","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"6","cantidad":"2"},{"id_venta":"3","fecha_venta":"2019-04-10","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"5","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"5","cantidad":"4"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL011","venta":"3","detalle":[{"id_venta":"3","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"7","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"7","cantidad":"5"},{"id_venta":"3","fecha_venta":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"9","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"9","cantidad":"5"},{"id_venta":"3","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"7","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"7","cantidad":"2"},{"id_venta":"3","fecha_venta":"2019-04-10","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","vendido":"5","valor_producto":"3500","total_devuelto":"","vendido-devuelto":"5","cantidad":"3"},{"id_venta":"3","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"5","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"5","cantidad":"5"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL015","venta":"10","detalle":[{"id_venta":"10","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"5","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"5","cantidad":"5"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"6","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"10","fecha_venta":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-10","cliente":"CL016","venta":"6","detalle":[{"id_venta":"6","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"7","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"},{"id_venta":"6","fecha_venta":"2019-04-10","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"8","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"8","cantidad":"1"},{"id_venta":"6","fecha_venta":"2019-04-10","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"6","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"6","fecha_venta":"2019-04-10","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","vendido":"9","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"9","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL002","venta":"14","detalle":[{"id_venta":"14","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"14","fecha_venta":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"10","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"10","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL002","venta":"14","detalle":[{"id_venta":"14","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"14","fecha_venta":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"10","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"10","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL002","venta":"14","detalle":[{"id_venta":"14","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"1","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"14","fecha_venta":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"10","valor_producto":"4500","total_devuelto":"1","vendido-devuelto":"9","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL002","venta":"14","detalle":[{"id_venta":"14","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"1","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"14","fecha_venta":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"10","valor_producto":"4500","total_devuelto":"1","vendido-devuelto":"9","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL004","venta":"16","detalle":[{"id_venta":"16","fecha_venta":"2019-04-11","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"7","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"16","fecha_venta":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"7","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"16","fecha_venta":"2019-04-11","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"8","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"8","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL004","venta":"16","detalle":[{"id_venta":"16","fecha_venta":"2019-04-11","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"7","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"16","fecha_venta":"2019-04-11","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"7","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"16","fecha_venta":"2019-04-11","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"8","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"8","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL007","venta":"11","detalle":[{"id_venta":"11","fecha_venta":"2019-04-11","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"7","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL007","venta":"11","detalle":[{"id_venta":"11","fecha_venta":"2019-04-11","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"7","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL007","venta":"19","detalle":[{"id_venta":"19","fecha_venta":"2019-04-11","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"7","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL007","venta":"19","detalle":[{"id_venta":"19","fecha_venta":"2019-04-11","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"7","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL009","venta":"15","detalle":[{"id_venta":"15","fecha_venta":"2019-04-11","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"7","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"},{"id_venta":"15","fecha_venta":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL009","venta":"15","detalle":[{"id_venta":"15","fecha_venta":"2019-04-11","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"7","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"},{"id_venta":"15","fecha_venta":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL010","venta":"12","detalle":[{"id_venta":"12","fecha_venta":"2019-04-11","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"9","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"9","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL010","venta":"12","detalle":[{"id_venta":"12","fecha_venta":"2019-04-11","producto":"9","descripcion_producto":"Maracuya Paquete x 3 Unidades","vendido":"9","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"9","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL010","venta":"20","detalle":[{"id_venta":"20","fecha_venta":"2019-04-11","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"9","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"},{"id_venta":"20","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"10","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"10","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL010","venta":"20","detalle":[{"id_venta":"20","fecha_venta":"2019-04-11","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"9","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"},{"id_venta":"20","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"10","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"10","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL011","venta":"13","detalle":[{"id_venta":"13","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"13","fecha_venta":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"10","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"10","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL011","venta":"13","detalle":[{"id_venta":"13","fecha_venta":"2019-04-11","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"9","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"9","cantidad":"3"},{"id_venta":"13","fecha_venta":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"10","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"10","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL014","venta":"18","detalle":[{"id_venta":"18","fecha_venta":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"7","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"18","fecha_venta":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"10","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"10","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-11","cliente":"CL014","venta":"18","detalle":[{"id_venta":"18","fecha_venta":"2019-04-11","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"7","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"7","cantidad":"1"},{"id_venta":"18","fecha_venta":"2019-04-11","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"10","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"10","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL004","venta":"13","detalle":[{"id_venta":"13","fecha_venta":"2019-04-10","producto":"16","descripcion_producto":"Frijol del Costal Bolsa x 500 gramos","vendido":"3","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"3","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL004","venta":"18","detalle":[{"id_venta":"18","fecha_venta":"2019-04-10","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"3","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"3","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL004","venta":"8","detalle":[{"id_venta":"8","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"15","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"15","cantidad":"3"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL004","venta":"8","detalle":[{"id_venta":"8","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"15","valor_producto":"7800","total_devuelto":"3","vendido-devuelto":"12","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL007","venta":"1","detalle":[{"id_venta":"1","fecha_venta":"2019-04-10","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"2","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"2","cantidad":"1"},{"id_venta":"1","fecha_venta":"2019-04-10","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"2","valor_producto":"1500","total_devuelto":"2","vendido-devuelto":"1","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL010","venta":"2","detalle":[{"id_venta":"2","fecha_venta":"2019-04-10","producto":"18","descripcion_producto":"Crema de leche Colanta Bolsa x 500 gramos","vendido":"1","valor_producto":"2200","total_devuelto":"","vendido-devuelto":"1","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL011","venta":"5","detalle":[{"id_venta":"5","fecha_venta":"2019-04-10","producto":"13","descripcion_producto":"Jabon Ariel Bolsa x 1 kg","vendido":"9","valor_producto":"7800","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL013","venta":"10","detalle":[{"id_venta":"10","fecha_venta":"2019-04-10","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"4","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"4","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL015","venta":"15","detalle":[{"id_venta":"15","fecha_venta":"2019-04-10","producto":"6","descripcion_producto":"Ma\u00edz trillado Bolsa x 1 kg","vendido":"2","valor_producto":"900","total_devuelto":"","vendido-devuelto":"2","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-12","cliente":"CL016","venta":"9","detalle":[{"id_venta":"9","fecha_venta":"2019-04-10","producto":"4","descripcion_producto":"Lentejas Bolsa x 500 gramos","vendido":"5","valor_producto":"1000","total_devuelto":"","vendido-devuelto":"5","cantidad":"2"},{"id_venta":"9","fecha_venta":"2019-04-10","producto":"8","descripcion_producto":"Kiwi Paquete x 3 Unidades","vendido":"4","valor_producto":"2000","total_devuelto":"","vendido-devuelto":"4","cantidad":"1"},{"id_venta":"9","fecha_venta":"2019-04-10","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"2","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"2","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-04-30","cliente":"CL012","venta":"9","detalle":[{"id_venta":"9","fecha_venta":"2019-04-29","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"10","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"10","cantidad":"2"},{"id_venta":"9","fecha_venta":"2019-04-29","producto":"17","descripcion_producto":"Mantequilla Don Oleo Unidad","vendido":"8","valor_producto":"3500","total_devuelto":"","vendido-devuelto":"8","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-05-07","cliente":"CL016","venta":"12","detalle":[{"id_venta":"12","fecha_venta":"2019-05-04","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","vendido":"8","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"8","cantidad":"1"},{"id_venta":"12","fecha_venta":"2019-05-04","producto":"15","descripcion_producto":"Arroz Buen Dia Bolsa x 500 gramos","vendido":"6","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"12","fecha_venta":"2019-05-04","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"9","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"9","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-05-09","cliente":"CL015","venta":"16","detalle":[{"id_venta":"16","fecha_venta":"2019-05-04","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"7","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"7","cantidad":"2"},{"id_venta":"16","fecha_venta":"2019-05-04","producto":"7","descripcion_producto":"Lechuga Bolsa x 500 gramos","vendido":"7","valor_producto":"1500","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"},{"id_venta":"16","fecha_venta":"2019-05-04","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"6","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-05-10","cliente":"CL001","venta":"13","detalle":[{"id_venta":"13","fecha_venta":"2019-05-04","producto":"2","descripcion_producto":"Lecha entera Celema Bolsa x 1000 cc","vendido":"8","valor_producto":"1900","total_devuelto":"","vendido-devuelto":"8","cantidad":"2"},{"id_venta":"13","fecha_venta":"2019-05-04","producto":"3","descripcion_producto":"Mandarinas Bolsa x 12 unidades","vendido":"6","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"6","cantidad":"6"},{"id_venta":"13","fecha_venta":"2019-05-04","producto":"10","descripcion_producto":"Cereal Madagascar Bolsa x 500 gramos","vendido":"5","valor_producto":"3000","total_devuelto":"","vendido-devuelto":"5","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-05-21","cliente":"CL010","venta":"14","detalle":[{"id_venta":"14","fecha_venta":"2019-05-04","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"6","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"6","cantidad":"1"},{"id_venta":"14","fecha_venta":"2019-05-04","producto":"11","descripcion_producto":"Cafe Monumental Bolsa x 500 gramos","vendido":"7","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"7","cantidad":"3"},{"id_venta":"14","fecha_venta":"2019-05-04","producto":"14","descripcion_producto":"Manzanas Paquete x 3 Unidades","vendido":"8","valor_producto":"4500","total_devuelto":"","vendido-devuelto":"8","cantidad":"5"},{"id_venta":"14","fecha_venta":"2019-05-04","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"10","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"10","cantidad":"2"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-05-24","cliente":"CL009","venta":"8","detalle":[{"id_venta":"8","fecha_venta":"2019-04-15","producto":"19","descripcion_producto":"Jabon en polvo Josefina Bolsa x 1 kg","vendido":"7","valor_producto":"4000","total_devuelto":"","vendido-devuelto":"7","cantidad":"2"},{"id_venta":"8","fecha_venta":"2019-04-15","producto":"20","descripcion_producto":"Crema dental Colgate Unidad","vendido":"5","valor_producto":"1800","total_devuelto":"","vendido-devuelto":"5","cantidad":"1"}]}');
SELECT * FROM insertar_devolucion_venta('{"fecha":"2019-05-24","cliente":"CL014","venta":"6","detalle":[{"id_venta":"6","fecha_venta":"2019-04-10","producto":"5","descripcion_producto":"Arroz Do\u00f1a Pepa Bolsa x 500 gramos","vendido":"3","valor_producto":"1200","total_devuelto":"","vendido-devuelto":"3","cantidad":"1"}]}');

SELECT * FROM insertar_pago_cliente('CL001', 3000, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL001', 33, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL001', 400, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL002', 100, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL004', 10000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL004', 100000, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL004', 17000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL004', 17000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL004', 2000, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL004', 400, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL006', 2200, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL006', 3800, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL006', 4500, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL006', 800, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL007', 1000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 1000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 10000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 10000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 11500, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 11500, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 20000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 3400, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL007', 4000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL007', 5800, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 650, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL007', 650, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL008', 10000, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL009', 1000, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL009', 1000, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL009', 200, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL009', 200, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL009', 500, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL009', 500, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 100, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 100, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 100, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL010', 15000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 15000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 300, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 400, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 400, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 600, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL010', 8000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL010', 8000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL011', 1000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL011', 10000, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL011', 10200, '2019-04-19');
SELECT * FROM insertar_pago_cliente('CL011', 2800, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL011', 3000, '2019-04-01');
SELECT * FROM insertar_pago_cliente('CL011', 3000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL011', 3000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL011', 800, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL012', 100, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL012', 800, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL013', 400, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL013', 500, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 1000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 1000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 1000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 10000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 10000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 10000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 10000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL014', 10000, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL015', 200, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL015', 200, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL015', 200, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL015', 2000, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL016', 100, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL016', 100, '2019-04-10');
SELECT * FROM insertar_pago_cliente('CL016', 1000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL016', 1000, '2019-04-12');
SELECT * FROM insertar_pago_cliente('CL016', 2000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL016', 2000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL016', 4000, '2019-04-11');
SELECT * FROM insertar_pago_cliente('CL016', 500, '2019-04-10');