"""
Hola perras, aca voy a dejar unas funciones de autenticacion
"""
import re


def contraseña_valida(contra):
    estado = False
    if len(contra) > 8:
        if re.search(r'[a-zA-Z]',contra ) and re.search(r'\d', contra):
            estado = True
    return estado


