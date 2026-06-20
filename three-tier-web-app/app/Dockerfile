FROM python:3.11-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt && \
    pip uninstall -y setuptools wheel

EXPOSE 5002 

# 5002 this is for local dev

CMD ["python", "app.py"]
