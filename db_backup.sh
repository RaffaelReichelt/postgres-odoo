#!/bin/bash

# Konfigurationsvariablen
DB_NAME="odoo"               # Name der Odoo-Datenbank
BACKUP_DIR="/opt/bitnami/postgresql/backups"  # Verzeichnis für Backups
BACKUP_DAYS=180                # Anzahl der Tage, die Backups aufbewahrt werden sollen

# Datum für den Dateinamen
DATE=$(date +"%Y-%m-%d_%H-%M")

# Backup-Verzeichnis erstellen, falls nicht vorhanden
mkdir -p $BACKUP_DIR

#PostgreSQL-Dump ausführen und komprimieren
# PGPASSWORD="._e05]9YSdQ5eET/" pg_dump -O -h localhost -U postgres -F c -b -v -f "$BACKUP_DIR/odoo_backup_$DATE.dump" $DB_NAME
PGPASSWORD="postgres" pg_dump -O -h localhost -U postgres -F c -b -v -f "$BACKUP_DIR/odoo_backup_$DATE.dump" $DB_NAME
# Alte Backups löschen (älter als $BACKUP_DAYS)
find $BACKUP_DIR -name "odoo_backup_*" -type f -mtime +$BACKUP_DAYS -delete

echo "Backup der Odoo-Datenbank $DB_NAME wurde erstellt: $BACKUP_DIR/odoo_backup_$DATE.dump"