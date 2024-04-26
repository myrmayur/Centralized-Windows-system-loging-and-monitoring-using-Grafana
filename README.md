# Grafana Installation Guide

1. **Update Package Lists**:
    ```bash
    sudo apt update
    ```

2. **Install Dependencies**:
    ```bash
    sudo apt install -y software-properties-common wget
    ```

3. **Add Grafana APT Repository**:
    ```bash
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    ```

4. **Install Grafana**:
    ```bash
    sudo apt update
    sudo apt install -y grafana
    ```

5. **Start Grafana Service**:
    ```bash
    sudo systemctl start grafana-server
    ```

6. **Enable Grafana Service to Start on Boot**:
    ```bash
    sudo systemctl enable grafana-server
    ```

7. **Verify Grafana Service Status**:
    ```bash
    sudo systemctl status grafana-server
    ```

8. **Access Grafana Web Interface**:
   - Open a web browser and navigate to `http://localhost:3000` or `http://YOUR_SERVER_IP:3000` to access the Grafana web interface.
   - Default credentials: Username: `admin`, Password: `admin` (You'll be prompted to change the password on first login)

9. **Optional: Configure Reverse Proxy (e.g., Nginx)**:
   - If you want to access Grafana over HTTPS or proxy requests through a web server like Nginx, configure a reverse proxy. 
