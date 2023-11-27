<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión / Registrarse</title>
    <link rel="stylesheet" type="text/css" href="{{ url_for('static', filename= 'estilo_login.css') }}">

</head>
<body>

    <div class="login-container">
        <h2>Bienvenido</h2>
        <div class="toggle-buttons">
            <button onclick="showLoginForm()">Iniciar Sesión</button>
            <button onclick="showRegisterForm()">Registrarse</button>
        </div>
        <form class="login-form" id="loginForm">
            <div class="form-group">
                <label for="username">Usuario:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Contraseña:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label for="user-type">Tipo de Usuario:</label>
                <select id="user-type" name="user-type" required>
                    <option value="padre">Padre</option>
                    <option value="profesional">Profesional</option>
                </select>
            </div>
            <div class="form-group">
                <button type="submit">Iniciar Sesión</button>
            </div>
        </form>
        <form class="login-form" id="registerForm" style="display: none;">
            <div class="form-group">
                <label for="reg-username">Usuario:</label>
                <input type="text" id="reg-username" name="reg-username" required>
            </div>
            <div class="form-group">
                <label for="reg-password">Contraseña:</label>
                <input type="password" id="reg-password" name="reg-password" required>
            </div>
            <div class="form-group">
                <label for="confirm-password">Confirmar Contraseña:</label>
                <input type="password" id="confirm-password" name="confirm-password" required>
            </div>
            <div class="form-group">
                <label for="email">Correo Electrónico:</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <button type="submit">Registrarse</button>
            </div>
        </form>
    </div>

    <script>
        function showLoginForm() {
            document.getElementById("loginForm").style.display = "block";
            document.getElementById("registerForm").style.display = "none";
        }

        function showRegisterForm() {
            document.getElementById("loginForm").style.display = "none";
            document.getElementById("registerForm").style.display = "block";
        }
    </script>

</body>
</html>
