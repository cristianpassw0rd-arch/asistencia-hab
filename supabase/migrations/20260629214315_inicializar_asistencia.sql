-- ====================================================================
-- 1. TIPOS DE ENUM Y ROLES DE USUARIO
-- ====================================================================
CREATE TYPE user_role AS ENUM ('admin', 'administrativo', 'usuario');
CREATE TYPE turno_type AS ENUM ('MATUTINO', 'VESPERTINO');
CREATE TYPE personal_tipo AS ENUM ('DOCENTE', 'INSPECTOR', 'BIBLIOTECARIA', 'ADMINISTRATIVO');

-- ====================================================================
-- 2. TABLA DE USUARIOS DEL SISTEMA (Para la App)
-- ====================================================================
CREATE TABLE usuarios_sistema (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    rol user_role NOT NULL DEFAULT 'usuario',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ====================================================================
-- 3. TABLA DE PERSONAL (Maestro de Docentes, Inspectores, etc.)
-- ====================================================================
CREATE TABLE personal (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL, -- Ej: 'GRETTEL', 'DANIA'
    tipo personal_tipo NOT NULL,
    nivel TEXT, -- Ej: 'II', 'III', '1', '2'
    seccion TEXT, -- Ej: 'A', 'B'
    turno turno_type NOT NULL,
    genero CHAR(1) CHECK (genero IN ('M', 'F')) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ====================================================================
-- 4. REGISTRO DE ASISTENCIA DIARIA DEL PERSONAL
-- ====================================================================
CREATE TABLE asistencia_personal (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    personal_id UUID REFERENCES personal(id) ON DELETE CASCADE NOT NULL,
    fecha DATE NOT NULL,
    asistio BOOLEAN NOT NULL DEFAULT TRUE, -- TRUE = Presente, FALSE = Ausente
    observacion TEXT,
    registrado_por UUID REFERENCES usuarios_sistema(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE (personal_id, fecha) -- Evita duplicados el mismo día
);

-- ====================================================================
-- 5. REGISTRO DIARIO DE MATRÍCULA Y ASISTENCIA DE ESTUDIANTES
-- ====================================================================
-- Replica las filas de tu Excel por modalidad, sexo y estado (esperado vs real)
CREATE TABLE asistencia_estudiantes_resumen (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fecha DATE NOT NULL,
    turno turno_type NOT NULL,
    modalidad TEXT NOT NULL, -- Ej: 'PREESCOLAR FORMAL PURO', 'PRIMARIA REGULAR'
    
    -- Estudiantes Esperados (Matrícula inicial)
    estudiantes_esperados_m INT NOT NULL DEFAULT 0,
    estudiantes_esperados_f INT NOT NULL DEFAULT 0,
    
    -- Estudiantes Reales (Asistencia del día)
    estudiantes_reales_m INT NOT NULL DEFAULT 0,
    estudiantes_reales_f INT NOT NULL DEFAULT 0,
    
    registrado_por UUID REFERENCES usuarios_sistema(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE (fecha, turno, modalidad) -- Evita duplicados estadísticos
);

-- ====================================================================
-- 6. ÍNDICES OPTIMIZADOS PARA REPORTES Y GRÁFICOS VELOCES
-- ====================================================================
CREATE INDEX idx_asistencia_pers_fecha ON asistencia_personal(fecha);
CREATE INDEX idx_asistencia_est_fecha ON asistencia_estudiantes_resumen(fecha);