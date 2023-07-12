#!/bin/bash

# This script sets up a Python virtual environment and installs the required packages for running the ML workflow scripts in the ml directory
python3 -m venv ./venv
source ./venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt