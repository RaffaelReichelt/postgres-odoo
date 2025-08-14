#!/bin/bash

# Konfigurationsvariablen
DB_NAME="odoo"               # Name der Odoo-Datenbank
DB_HOST="127.0.0.1"
DB_PORT="54321"              # Port der PostgreSQL-Datenbank
BACKUP_DIR="/opt/docker/postgres/odoo/backups"  # Verzeichnis für Backups
PG_PASSWORD="postgres"       # PostgreSQL-Passwort

# Datum und Zeitvariablen für die Rotation
DATE=$(date +%Y%m%d-%H%M%S)
HOUR=$(date +%H)
DAY=$(date +%d)
WEEKDAY=$(date +%u)  # 1-7, wobei 1 für Montag steht
MONTH=$(date +%m)

# Backup-Verzeichnis erstellen, falls nicht vorhanden
mkdir -p $BACKUP_DIR

# Funktion zum Erstellen eines Datenbank-Backups
create_backup() {
    local backup_type=$1
    local filename="${BACKUP_DIR}/odoo_${backup_type}_${DATE}.dump"
    
    echo "Erstelle ${backup_type} Backup: $filename"
    PGPASSWORD="${PG_PASSWORD}" pg_dump -O -h ${DB_HOST} -p ${DB_PORT} -U postgres -F c -b -v -f "$filename" $DB_NAME
    
    if [ $? -eq 0 ]; then
        echo "Backup der Odoo-Datenbank $DB_NAME wurde erstellt: $filename"
        return 0
    else
        echo "FEHLER: Backup konnte nicht erstellt werden!"
        return 1
    fi
}

# Funktion zum Löschen alter Backups gemäß Rotationsrichtlinien
rotate_backups() {
    echo "Starte Backup-Rotation..."
    
    # Stündliche Backups - behalte die letzten 24 Stunden
    echo "Rotiere stündliche Backups..."
    find $BACKUP_DIR -name "odoo_hourly_*" -type f -mtime +1 -delete
    
    # Tägliche Backups - behalte die letzten 7 Tage
    echo "Rotiere tägliche Backups..."
    find $BACKUP_DIR -name "odoo_daily_*" -type f -mtime +7 -delete
    
    # Wöchentliche Backups - behalte die letzten 5 Wochen
    echo "Rotiere wöchentliche Backups..."
    find $BACKUP_DIR -name "odoo_weekly_*" -type f -mtime +30 -delete
    
    # Monatliche Backups - behalte die letzten 12 Monate
    echo "Rotiere monatliche Backups..."
    find $BACKUP_DIR -name "odoo_monthly_*" -type f -mtime +365 -delete
    
    echo "Backup-Rotation abgeschlossen."
}

# Bestimme Backup-Typ basierend auf Zeit
BACKUP_TYPE="hourly"

# Am ersten Tag jedes Monats um Mitternacht: monatliches Backup
if [ "$DAY" = "01" ] && [ "$HOUR" = "00" ]; then
    BACKUP_TYPE="monthly"
# Jeden Montag um Mitternacht: wöchentliches Backup
elif [ "$WEEKDAY" = "1" ] && [ "$HOUR" = "00" ]; then
    BACKUP_TYPE="weekly"
# Täglich um Mitternacht: tägliches Backup
elif [ "$HOUR" = "00" ]; then
    BACKUP_TYPE="daily"
fi

# Führe Backup durch
create_backup $BACKUP_TYPE

# Führe die Backup-Rotation durch
rotate_backups