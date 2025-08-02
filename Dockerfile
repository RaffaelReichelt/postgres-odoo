FROM docker.io/bitnami/postgresql:16.6.0-debian-12-r2
USER root
RUN apt update && apt install  -y nano cron 
COPY ./db_backup.sh /opt/bitnami/scripts/postgresql/
COPY ./cronjob /etc/cron.d/db_backup
RUN chmod 0644 /etc/cron.d/db_backup
RUN crontab /etc/cron.d/db_backup
RUN touch /var/log/cron.log
RUN chmod +x /opt/bitnami/scripts/postgresql/db_backup.sh
RUN chmod +x /etc/cron.d/db_backup
RUN mkdir -p /opt/bitnami/postgresql/backups
RUN cron
USER 1001