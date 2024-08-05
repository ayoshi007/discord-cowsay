from flask import Flask, make_response
import cowsay

app = Flask(__name__)


@app.post("/")
def root():
    return make_response(f"{cowsay.get_output_string('cow', 'moo')}")
