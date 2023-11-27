-- Intentar cambiar al contexto de la base de datos maestra
USE master;
GO

-- Verificar si la base de datos existe, si no, crearla
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Consultorio')
BEGIN
    CREATE DATABASE Consultorio;
END
GO

-- Cambiar al contexto de la base de datos Consultorio
USE Consultorio;
GO

-- Crear la tabla para el ingreso
CREATE TABLE ingreso (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(255) NOT NULL,
	hashed_password NVARCHAR(255) NOT NULL,  -- Almacenar el hash de la contraseña
    password NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    tipo_usuario NVARCHAR(20) NOT NULL, -- Agregado: Tipo de usuario (padre o profesional)
    CONSTRAINT CHK_TipoUsuario CHECK (tipo_usuario IN ('padre', 'profesional'))
);
GO

-- Crear la tabla para la información del usuario y contraseña
CREATE TABLE usuario_contraseña (
    id INT PRIMARY KEY,
    username NVARCHAR(255) NOT NULL,
    password NVARCHAR(255) NOT NULL,
    pregunta_recuperacion_1 NVARCHAR(255) NOT NULL,
    respuesta_recuperacion_1 NVARCHAR(255) NOT NULL,
    pregunta_recuperacion_2 NVARCHAR(255) NOT NULL,
    respuesta_recuperacion_2 NVARCHAR(255) NOT NULL,
    pregunta_recuperacion_3 NVARCHAR(255) NOT NULL,
    respuesta_recuperacion_3 NVARCHAR(255) NOT NULL,
    tipo_usuario NVARCHAR(20) NOT NULL,
    FOREIGN KEY (id) REFERENCES ingreso(id)
);
GO

-- Crear procedimiento almacenado para el registro de usuarios
CREATE PROCEDURE RegistrarUsuario
    @username NVARCHAR(255),
    @password NVARCHAR(255),
    @email NVARCHAR(255),
    @tipo_usuario NVARCHAR(20)
AS
BEGIN
    -- Verificar si el tipo de usuario es válido
    IF @tipo_usuario IN ('padre', 'profesional')
    BEGIN
        -- Verificar si el nombre de usuario no existe
        IF NOT EXISTS (SELECT 1 FROM ingreso WHERE username = @username)
        BEGIN
			 -- Calcular el hash de la contraseña y almacenarla
            DECLARE @hashed_password NVARCHAR(255);
            SET @hashed_password = HASHBYTES('SHA2_256', @password);   

			-- Insertar nuevo usuario
            INSERT INTO ingreso (username, password, email, tipo_usuario)
            VALUES (@username, @password, @email, @tipo_usuario);

            -- Obtener el ID del nuevo usuario
            DECLARE @nuevoUsuarioID INT;
            SET @nuevoUsuarioID = SCOPE_IDENTITY();

            -- Insertar en la tabla de usuario_contraseña
            INSERT INTO usuario_contraseña (id, username, password, 
                pregunta_recuperacion_1, respuesta_recuperacion_1, 
                pregunta_recuperacion_2, respuesta_recuperacion_2, 
                pregunta_recuperacion_3, respuesta_recuperacion_3, 
                tipo_usuario)
            VALUES (@nuevoUsuarioID, @username, @password, 
                '', '', 
                '', '', 
                '', '', 
                @tipo_usuario);

            PRINT 'Usuario registrado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'Error: El nombre de usuario ya existe. Por favor, elige otro nombre de usuario.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: Tipo de usuario no válido. Debe ser "padre" o "profesional".';
    END
END;
GO

-- Crear la tabla para padres
CREATE TABLE padre (
    id INT PRIMARY KEY,
    nombre NVARCHAR(255) NOT NULL,
    apellido NVARCHAR(255) NOT NULL,
	DNI INT,
    fecha_nacimiento DATE NOT NULL,
    zona NVARCHAR(255) NOT NULL,
    FOREIGN KEY (id) REFERENCES ingreso(id)
);
GO

-- Crear la tabla para profesionales
CREATE TABLE profesional (
    id INT PRIMARY KEY,
    nombre NVARCHAR(255) NOT NULL,
    apellido NVARCHAR(255) NOT NULL,
    especialidad NVARCHAR(255) NOT NULL,
    usuario_id INT,
    correo NVARCHAR(50),
    numero_matricula INT,
    celular NVARCHAR(50),
    zona_vive NVARCHAR(50),
    FOREIGN KEY (usuario_id) REFERENCES ingreso(id)
);
GO

-- Crear la tabla para datos profesionales
CREATE TABLE datos_profesionales (
    id INT IDENTITY(1,1) PRIMARY KEY,
    profesional_id INT,
    genero NVARCHAR(50),
    edad INT,
    descripcion NVARCHAR(MAX),
    experiencia NVARCHAR(MAX),
    zona NVARCHAR(MAX),
    otros NVARCHAR(MAX),
    FOREIGN KEY (profesional_id) REFERENCES profesional(id)
);
GO

-- Crear la tabla para pacientes
CREATE TABLE pacientes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(255) NOT NULL,
    apellido NVARCHAR(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    edad INT NOT NULL,
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    diagnostico NVARCHAR(MAX) NOT NULL,
    padre_id INT NOT NULL,
    madre_id INT NOT NULL,
    profesional_id INT NOT NULL, -- Corregido: Agregada referencia a profesional_id
    motivo_consulta NVARCHAR(MAX) NOT NULL,
    escuela_asiste NVARCHAR(255),
    grado NVARCHAR(50),
    certificado_discapacidad NVARCHAR(MAX),
    obra_social NVARCHAR(255),
    FOREIGN KEY (padre_id) REFERENCES ingreso(id),
    FOREIGN KEY (madre_id) REFERENCES ingreso(id),
    FOREIGN KEY (profesional_id) REFERENCES profesional(id)
);
GO

-- Crear la tabla para agendamiento
CREATE TABLE agendamiento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    paciente_id INT,
    profesional_id INT,
    fecha_hora DATETIME NOT NULL,
    confirmado CHAR(1) DEFAULT 'N' NOT NULL CHECK (confirmado IN ('S', 'N')),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    FOREIGN KEY (profesional_id) REFERENCES profesional(id)
);
GO

-- Procedimientos almacenados

-- Procedimiento para que un profesional ingrese la información de un paciente
CREATE PROCEDURE IngresarInformacionPaciente
    @profesionalID INT, -- ID del profesional que ingresa la información
    @nombrePaciente NVARCHAR(255),
    @apellidoPaciente NVARCHAR(255),
    @nuevaFechaNacimiento DATE,
    @nuevaEdad INT,
    @nuevoSexo CHAR(1),
    @nuevoDiagnostico NVARCHAR(MAX),
    @padre INT,
    @madre INT,
    @nuevoMotivoConsulta NVARCHAR(MAX),
    @nuevaEscuelaAsiste NVARCHAR(255),
    @nuevoGrado NVARCHAR(50),
    @nuevoCertificadoDiscapacidad NVARCHAR(MAX),
    @nuevaObraSocial NVARCHAR(255)
    
AS
BEGIN
    -- Verifica si el usuario es un profesional
    IF EXISTS (SELECT 1 FROM ingreso WHERE id = @profesionalID AND tipo_usuario = 'profesional')
    BEGIN
        -- Inserta la información del paciente
        INSERT INTO pacientes (nombre, apellido, fecha_nacimiento, edad, sexo, diagnostico, padre_id, madre_id, profesional_id, motivo_consulta, escuela_asiste, grado, certificado_discapacidad, obra_social) 
        VALUES (@nombrePaciente, @apellidoPaciente, @nuevaFechaNacimiento, @nuevaEdad, @nuevoSexo, @nuevoDiagnostico, @padre, @madre, @profesionalID, @nuevoMotivoConsulta, @nuevaEscuelaAsiste, @nuevoGrado, @nuevoCertificadoDiscapacidad, @nuevaObraSocial);

        PRINT 'Información del paciente ingresada correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'Acceso no autorizado. Este procedimiento solo puede ser ejecutado por un profesional.';
    END
END;
GO

-- Procedimiento para que un profesional confirme una sesión
CREATE PROCEDURE ConfirmarSesionPaciente
    @profesionalID INT,
    @pacienteID INT,
    @confirmado CHAR(1) = 'S'
AS
BEGIN
    -- Verifica si el usuario es un profesional
    IF EXISTS (SELECT 1 FROM ingreso WHERE id = @profesionalID AND tipo_usuario = 'profesional')
    BEGIN
        -- Verifica si el paciente pertenece al profesional
        IF EXISTS (SELECT 1 FROM agendamiento WHERE paciente_id = @pacienteID AND profesional_id = @profesionalID)
        BEGIN
            -- Actualiza la confirmación de la sesión
            UPDATE agendamiento
            SET confirmado = @confirmado
            WHERE paciente_id = @pacienteID;

            PRINT 'Sesión confirmada correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'Acceso no autorizado. Este paciente no pertenece al profesional.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Acceso no autorizado. Este procedimiento solo puede ser ejecutado por un profesional.';
    END
END;
GO

-- Procedimiento para que un padre ingrese su información personal y seleccione una sesión
CREATE PROCEDURE IngresarInformacionPadre
    @padreID INT,
    @nombrePadre NVARCHAR(255),
    @apellidoPadre NVARCHAR(255),
	@DNI INT,
    @fecha_nacimiento DATE,
    @zona NVARCHAR (255),
    @pacienteID INT, -- ID del paciente al que desea asignar una sesión
    @fechaHoraSesion DATETIME
AS
BEGIN
    -- Verifica si el usuario es un padre
    IF EXISTS (SELECT 1 FROM ingreso WHERE id = @padreID AND tipo_usuario = 'padre')
    BEGIN
        -- Inserta la información del padre
        INSERT INTO padre (id, nombre, apellido,DNI, fecha_nacimiento, zona) 
        VALUES (@padreID, @nombrePadre, @apellidoPadre, @DNI, @fecha_nacimiento, @zona);

        -- Inserta el registro de usuario
        EXEC RegistrarUsuario @nombrePadre, '', '', 'padre';

        -- Inserta la sesión para el paciente
        INSERT INTO agendamiento (paciente_id, profesional_id, fecha_hora) 
        VALUES (@pacienteID, NULL, @fechaHoraSesion);

        PRINT 'Información del padre ingresada correctamente y sesión asignada.';
    END
    ELSE
    BEGIN
        PRINT 'Acceso no autorizado. Este procedimiento solo puede ser ejecutado por un padre.';
    END
END;
GO

-- Procedimiento para que un usuario (modo padre) llene sus datos personales y elija un agendamiento
CREATE PROCEDURE LlenarDatosYAgendar
    @usuarioID INT, -- ID del usuario (padre)
    @nombre NVARCHAR(255),
    @apellido NVARCHAR(255),
    @fechaNacimiento DATE,
    @zona NVARCHAR(255),
    @pacienteID INT,
    @fechaHoraSesion DATETIME
AS
BEGIN
    -- Verifica si el usuario es un padre
    IF EXISTS (SELECT 1 FROM ingreso WHERE id = @usuarioID AND tipo_usuario = 'padre')
    BEGIN
        -- Inserta los datos personales del padre si aún no existen
        IF NOT EXISTS (SELECT 1 FROM padre WHERE id = @usuarioID)
        BEGIN
            INSERT INTO padre (id, nombre, apellido, fecha_nacimiento, zona) 
            VALUES (@usuarioID, @nombre, @apellido, @fechaNacimiento, @zona);
        END

        -- Verifica si el agendamiento seleccionado pertenece al usuario (padre)
        IF EXISTS (SELECT 1 FROM agendamiento WHERE id = @pacienteID AND paciente_id = @usuarioID)
        BEGIN
            -- Actualiza la sesión para el paciente
            UPDATE agendamiento
            SET fecha_hora = @fechaHoraSesion
            WHERE paciente_id = @pacienteID;

            PRINT 'Datos personales llenados y agendamiento seleccionado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'Acceso no autorizado. Este agendamiento no pertenece al usuario (padre).';
        END
    END
    ELSE
    BEGIN
        PRINT 'Acceso no autorizado. Este procedimiento solo puede ser ejecutado por un usuario (padre).';
    END
END;
GO
