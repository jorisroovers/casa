
export GRAFANA_URL="http://localhost:{{grafana_port}}"
export GRAFANA_TOKEN="{{grafana_backups_api_token}}"
DASHBOARD_BACKUPS_DIR="$DIRECTORY/dashboards"

mkdir "$DASHBOARD_BACKUPS_DIR"

source "{{grafana_backups_venv}}/bin/activate"
python {{grafana_backups_dir}}/grafana-backup-tool/saveDashboards.py "$DASHBOARD_BACKUPS_DIR"
