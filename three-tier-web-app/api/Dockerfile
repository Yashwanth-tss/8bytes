FROM python:3.11-slim

WORKDIR /api

# Copy the Python dependencies file first to leverage Docker cache layers
COPY requirements.txt ./

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5001

CMD ["python", "api.py"]