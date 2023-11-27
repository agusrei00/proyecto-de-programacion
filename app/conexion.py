#Conexion a la base de datos

import pyodbc

#Datos de la base de datos
server = 'NOTE-FACU\\SQLEXPRESS'
bd = 'Pediatrics'
usuario = 'sa'
contrasenia = 'Blink317'

try:
    conexion = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='
                                +bd+';UID='+usuario+';PWD='+contrasenia)
    print('Conexion completa')
except:
    print('Error')