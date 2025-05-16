#!/bin/bash

cd lambda
pip install --target . pytz > /dev/null 2>&1
zip -r app.zip . > /dev/null
cd ..
