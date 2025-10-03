FROM python:3.11-slim
WORKDIR /app

# --- psql dentro de la imagen ---
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# tu código + los .sql
COPY . /app/etl/python/

# ENTRYPOINT por defecto (lo puedes sobreescribir con --entrypoint)
ENTRYPOINT ["python","/app/etl/python/load_prescripcion_stream.py"]
