#!/bin/bash
set -e

dnf update -y
dnf install -y python3 python3-pip

# Install Python packages.
# Installing both database drivers keeps the script simple for PostgreSQL or MySQL.
pip3 install flask gunicorn psycopg2-binary pymysql

# Get EC2 metadata using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

# Create app directory
mkdir -p /opt/cloudops-app

# Create Flask app
cat <<'APP_EOF' > /opt/cloudops-app/app.py
import os
from flask import Flask

app = Flask(__name__)

INSTANCE_ID = os.environ.get("INSTANCE_ID", "unknown")
AZ = os.environ.get("AZ", "unknown")
PRIVATE_IP = os.environ.get("PRIVATE_IP", "unknown")

DB_ENGINE = os.environ.get("DB_ENGINE", "postgres")
DB_HOST = os.environ.get("DB_HOST")
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_PORT = int(os.environ.get("DB_PORT", "5432"))


def check_db_connection():
    try:
        if DB_ENGINE == "postgres":
            import psycopg2

            conn = psycopg2.connect(
                host=DB_HOST,
                database=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                port=DB_PORT,
                connect_timeout=3
            )
            conn.close()
            return "Connected"

        elif DB_ENGINE == "mysql":
            import pymysql

            conn = pymysql.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASSWORD,
                database=DB_NAME,
                port=DB_PORT,
                connect_timeout=3
            )
            conn.close()
            return "Connected"

        return "Unsupported DB Engine"

    except Exception:
        return "Not Connected"


@app.route("/")
def home():
    db_status = check_db_connection()
    status_color = "#22c55e" if db_status == "Connected" else "#ef4444"

    return f"""
    <!DOCTYPE html>
    <html>
    <head>
      <title>HA3tier Portfolio App</title>
      <style>
        body {{
          font-family: Arial, sans-serif;
          background: #111827;
          color: #ffffff;
          text-align: center;
          padding-top: 70px;
        }}
        .card {{
          background: #1f2937;
          padding: 40px;
          border-radius: 16px;
          width: 760px;
          margin: auto;
          box-shadow: 0 10px 30px rgba(0,0,0,0.4);
        }}
        h1 {{
          color: #38bdf8;
          font-size: 34px;
        }}
        p {{
          font-size: 18px;
        }}
        .status {{
          color: {status_color};
          font-weight: bold;
        }}
        .small {{
          color: #9ca3af;
          font-size: 14px;
          margin-top: 30px;
        }}
      </style>
    </head>
    <body>
      <div class="card">
        <h1>Hello from HA3tier Portfolio App</h1>
        <p>This app is running behind an Application Load Balancer.</p>
        <p>Installed automatically using EC2 User Data from Terraform.</p>
        <p><strong>Instance ID:</strong> {INSTANCE_ID}</p>
        <p><strong>Availability Zone:</strong> {AZ}</p>
        <p><strong>Private IP:</strong> {PRIVATE_IP}</p>
        <p><strong>Database Engine:</strong> {DB_ENGINE}</p>
        <p><strong>Database Status:</strong> <span class="status">{db_status}</span></p>
        <p class="small">Architecture: ALB + Target Group + Auto Scaling Group + Launch Template + RDS</p>
      </div>
    </body>
    </html>
    """


@app.route("/health")
def health():
    return "OK", 200


@app.route("/db-health")
def db_health():
    db_status = check_db_connection()

    if db_status == "Connected":
        return "Database Connected", 200
    else:
        return "Database Not Connected", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
APP_EOF

# Install AWS CLI and jq for Secrets Manager access
dnf install -y awscli jq

# Retrieve database credentials from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${db_secret_arn}" \
  --region "${aws_region}" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# Write environment variables
cat <<ENV_EOF > /opt/cloudops-app/app.env
INSTANCE_ID=$INSTANCE_ID
AZ=$AZ
PRIVATE_IP=$PRIVATE_IP
DB_ENGINE=${db_engine}
DB_HOST=${db_endpoint}
DB_NAME=${db_name}
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_PORT=${db_port}
ENV_EOF

chmod 600 /opt/cloudops-app/app.env

# Create systemd service
cat <<'SERVICE_EOF' > /etc/systemd/system/cloudops-app.service
[Unit]
Description=CloudOps Portfolio Flask App
After=network.target

[Service]
WorkingDirectory=/opt/cloudops-app
EnvironmentFile=/opt/cloudops-app/app.env
ExecStart=/usr/local/bin/gunicorn --workers 2 --bind 0.0.0.0:80 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable cloudops-app
systemctl start cloudops-app