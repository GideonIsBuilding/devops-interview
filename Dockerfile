# Python Alpine image as a base
FROM python:3.10-alpine

# Working reference directory inside the container
WORKDIR /app

# Copy requirements file into container
COPY requirements.txt .

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of application code into container
COPY . .

# Expose port app runs on
EXPOSE 3000

# Run the application
CMD ["gunicorn", "-b", "0.0.0.0:3000", "app:app"]
