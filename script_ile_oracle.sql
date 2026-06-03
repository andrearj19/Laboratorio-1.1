-- ====================================================================
-- CASO DE ESTUDIO: INDUSTRIA LOJANA DE ESPECIERÍAS (ILE)
-- ====================================================================

-- ====================================================================
-- PASO 1: CREACIÓN DE LA ORGANIZACIÓN FÍSICA (TABLESPACES)
-- ====================================================================

CREATE TABLESPACE TS_ILE_DATOS 
DATAFILE 'ts_ile_datos01.dbf' 
SIZE 500M 
AUTOEXTEND ON 
NEXT 50M 
MAXSIZE 2G;

CREATE TABLESPACE TS_ILE_INDICES 
DATAFILE 'ts_ile_indices01.dbf' 
SIZE 200M 
AUTOEXTEND ON 
NEXT 20M 
MAXSIZE 1G;

CREATE TEMPORARY TABLESPACE TS_ILE_TEMP 
TEMPFILE 'ts_ile_temp01.dbf' 
SIZE 100M 
AUTOEXTEND ON 
NEXT 10M 
MAXSIZE 500M;

-- ====================================================================
-- PASO 2: CREACIÓN DEL MODELO LÓGICO (DDL - TABLAS Y RESTRICCIONES)
-- ====================================================================

-- 1. TABLA: CATEGORIA
CREATE TABLE categoria (
    id_categoria      NUMBER(10) NOT NULL,
    nombre_categoria  VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
    USING INDEX TABLESPACE TS_ILE_INDICES
) TABLESPACE TS_ILE_DATOS;

-- 2. TABLA: PRODUCTO
CREATE TABLE producto (
    id_producto   NUMBER(10) NOT NULL,
    nombre        VARCHAR2(100) NOT NULL,
    descripcion   VARCHAR2(200),
    precio        NUMBER(10,2) NOT NULL,
    stock         NUMBER(10) NOT NULL,
    id_categoria  NUMBER(10) NOT NULL,
    CONSTRAINT pk_producto PRIMARY KEY (id_producto)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
) TABLESPACE TS_ILE_DATOS;

-- 3. TABLA: EMPLEADO
CREATE TABLE empleado (
    id_empleado  NUMBER(10) NOT NULL,
    nombre       VARCHAR2(100) NOT NULL,
    cargo        VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado)
    USING INDEX TABLESPACE TS_ILE_INDICES
) TABLESPACE TS_ILE_DATOS;

-- 4. TABLA: PRODUCCION
CREATE TABLE produccion (
    id_produccion       NUMBER(10) NOT NULL,
    fecha               DATE DEFAULT SYSDATE NOT NULL,
    cantidad_producida  NUMBER(10) NOT NULL,
    id_producto         NUMBER(10) NOT NULL,
    id_empleado         NUMBER(10) NOT NULL,
    CONSTRAINT pk_produccion PRIMARY KEY (id_produccion)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_produccion_producto FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto),
    CONSTRAINT fk_produccion_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado)
) TABLESPACE TS_ILE_DATOS;

-- 5. TABLA: MATERIA_PRIMA
CREATE TABLE materia_prima (
    id_materia     NUMBER(10) NOT NULL,
    nombre         VARCHAR2(100) NOT NULL,
    unidad_medida  VARCHAR2(20) NOT NULL,
    stock          NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_materia_prima PRIMARY KEY (id_materia)
    USING INDEX TABLESPACE TS_ILE_INDICES
) TABLESPACE TS_ILE_DATOS;

-- 6. TABLA: DETALLE_PRODUCCION
CREATE TABLE detalle_produccion (
    id_detalle_produccion  NUMBER(10) NOT NULL,
    cantidad_utilizada     NUMBER(10,2) NOT NULL,
    id_produccion          NUMBER(10) NOT NULL,
    id_materia             NUMBER(10) NOT NULL,
    CONSTRAINT pk_detalle_produccion PRIMARY KEY (id_detalle_produccion)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_det_prod_produccion FOREIGN KEY (id_produccion)
        REFERENCES produccion (id_produccion),
    CONSTRAINT fk_det_prod_materia FOREIGN KEY (id_materia)
        REFERENCES materia_prima (id_materia)
) TABLESPACE TS_ILE_DATOS;

-- 7. TABLA: PROVEEDOR
CREATE TABLE proveedor (
    id_proveedor    NUMBER(10) NOT NULL,
    nombre_company  VARCHAR2(100) NOT NULL,
    ruc             VARCHAR2(13) NOT NULL,
    telefono        VARCHAR2(15),
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
    USING INDEX TABLESPACE TS_ILE_INDICES
) TABLESPACE TS_ILE_DATOS;

-- 8. TABLA: COMPRA
CREATE TABLE compra (
    id_compra     NUMBER(10) NOT NULL,
    fecha         DATE DEFAULT SYSDATE NOT NULL,
    total         NUMBER(10,2) NOT NULL,
    id_proveedor  NUMBER(10) NOT NULL,
    CONSTRAINT pk_compra PRIMARY KEY (id_compra)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_compra_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
) TABLESPACE TS_ILE_DATOS;

-- 9. TABLA: DETALLE_COMPRA
CREATE TABLE detalle_compra (
    id_detalle_compra  NUMBER(10) NOT NULL,
    cantidad           NUMBER(10,2) NOT NULL,
    precio_unitario    NUMBER(10,2) NOT NULL,
    subtotal           NUMBER(10,2) NOT NULL,
    id_compra          NUMBER(10) NOT NULL,
    id_materia         NUMBER(10) NOT NULL,
    CONSTRAINT pk_detalle_compra PRIMARY KEY (id_detalle_compra)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_det_compra_compra FOREIGN KEY (id_compra)
        REFERENCES compra (id_compra),
    CONSTRAINT fk_det_compra_materia FOREIGN KEY (id_materia)
        REFERENCES materia_prima (id_materia)
) TABLESPACE TS_ILE_DATOS;

-- 10. TABLA: CLIENTE
CREATE TABLE cliente (
    id_cliente  NUMBER(10) NOT NULL,
    nombres     VARCHAR2(50) NOT NULL,
    apellidos   VARCHAR2(50) NOT NULL,
    cedula      VARCHAR2(10) NOT NULL,
    direccion   VARCHAR2(100),
    telefono    VARCHAR2(15),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
    USING INDEX TABLESPACE TS_ILE_INDICES
) TABLESPACE TS_ILE_DATOS;

-- 11. TABLA: VENTA
CREATE TABLE venta (
    id_venta    NUMBER(10) NOT NULL,
    fecha       DATE DEFAULT SYSDATE NOT NULL,
    total       NUMBER(10,2) NOT NULL,
    id_cliente  NUMBER(10) NOT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
) TABLESPACE TS_ILE_DATOS;

-- 12. TABLA: DETALLE_VENTA
CREATE TABLE detalle_venta (
    id_detalle       NUMBER(10) NOT NULL,
    cantidad         NUMBER(10) NOT NULL,
    precio_unitario  NUMBER(10,2) NOT NULL,
    subtotal         NUMBER(10,2) NOT NULL,
    id_venta         NUMBER(10) NOT NULL,
    id_producto      NUMBER(10) NOT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_detalle)
    USING INDEX TABLESPACE TS_ILE_INDICES,
    CONSTRAINT fk_det_venta_venta FOREIGN KEY (id_venta)
        REFERENCES venta (id_venta),
    CONSTRAINT fk_det_venta_producto FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
) TABLESPACE TS_ILE_DATOS;

-- ====================================================================
-- PASO 3: CREACIÓN DE ÍNDICES ADICIONALES PARA LLAVES FORÁNEAS (FK)
-- ====================================================================

CREATE INDEX idx_fk_prod_cat ON producto(id_categoria) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_produccion_prod ON produccion(id_producto) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_produccion_emp ON produccion(id_empleado) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_det_prod_prod ON detalle_produccion(id_produccion) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_det_prod_mat ON detalle_produccion(id_materia) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_compra_prov ON compra(id_proveedor) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_det_comp_comp ON detalle_compra(id_compra) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_det_comp_mat ON detalle_compra(id_materia) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_venta_cli ON venta(id_cliente) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_det_vent_vent ON detalle_venta(id_venta) TABLESPACE TS_ILE_INDICES;
CREATE INDEX idx_fk_det_vent_prod ON detalle_venta(id_producto) TABLESPACE TS_ILE_INDICES;
