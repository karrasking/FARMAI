FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app/etl/python/
ENTRYPOINT ["python","/app/etl/python/load_prescripcion_stream.py"]
