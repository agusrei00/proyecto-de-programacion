from flask import Flask, render_template, redirect, request, url_for, session, make_response
import os
app = Flask(__name__,template_folder='templates', static_folder='static')


@app.route ('/')
def index():
    return render_template('Login.html')


if __name__ == '__main__':
    app.run(debug= True)
