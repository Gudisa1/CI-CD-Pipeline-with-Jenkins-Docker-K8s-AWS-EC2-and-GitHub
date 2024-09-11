FROM python:3.9-alpine

WORKDIR /flask_app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install pytest

COPY app/ .

# Copy the test directory to the working directory
COPY test/ ./test/

# Set the working directory to where your application code is
WORKDIR /flask_app

# Run the application by default
CMD [ "python", "app.py" ]
