#!/bin/sh
#set -e

##
## Startup Text
##
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "  Suitefish Docker Initialization"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

##
## Your startup commands here
##
echo "[SFD] Initialization: Executing entry point."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Update/Upgrade Handling
##
if [ "$sf_ct_update_on_start" = "1" ]; then
    echo "[SFD] Update: Update on Start is enabled. Performing Update."
    echo "[SFD] Update: Please wait, this may take a few Minutes."
    apt-get update -qq
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
elif [ "$sf_ct_update_on_start" = "0" ]; then
    echo "[SFD] Update: Update on Start is disabled."
else
    echo "[SFD] Update: Invalid Value for Variable: sf_ct_update_on_start."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Timezone Update
##
echo "[SFD] Timezone: Updating Time Zone Locale to $sf_timezone."
if [ -n "$sf_timezone" ]; then
    ln -snf "/usr/share/zoneinfo/$sf_timezone" /etc/localtime
    echo "$sf_timezone" > /etc/timezone
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Setup Permissions
##
echo "[SFD] Permissions: Setting Chmod to 0770 on: /var/www.";
chmod 0770 /var/www -R > /dev/null 2>&1
echo "[SFD] Permissions: Setting Owner to www-data on: /var/www.";
chown www-data:www-data /var/www -R > /dev/null 2>&1
echo "[SFD] Permissions: Setting Chmod to 0777 on: /opt/sf_log/*.";
chmod 0777 /opt/sf_log/ -R > /dev/null 2>&1
chmod 0777 /opt/sf_log -R > /dev/null 2>&1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Certificate Handling (including LetsEncrypt)
##
if [ "$sf_letsencrypt_enable" -eq 1 ]; then
    echo "[SFD] SSL-Certificate: LetsEncrypt Certificate creation is enabled."

    if ! command -v certbot >/dev/null 2>&1; then
        echo "[SFD] SSL-Certificate: Certbot not found, installing now."
        apt-get update -qq
		DEBIAN_FRONTEND=noninteractive apt-get install certbot -y -qq
        if [ $? -ne 0 ]; then
            echo "[SFD] SSL-Certificate: Certbot installation failed!"
			if [ ! -f "/opt/sf_ssl/privkey.pem" ] || [ ! -f "/opt/sf_ssl/cert.pem" ]; then
				echo "[SFD] SSL-Certificate: Certificate File cert.pem and privkey.pem NOT found in SSL-Storage."
				echo "[SFD] SSL-Certificate: Starting Custom Certificate Generation."
				unlink /opt/sf_ssl/privkey.pem > /dev/null 2>&1
				unlink /opt/sf_ssl/cert.pem > /dev/null 2>&1
				openssl req -x509 -nodes -days 7300 -newkey rsa:2048 \
				 -keyout /opt/sf_ssl/privkey.pem \
				 -out /opt/sf_ssl/cert.pem \
				 -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=example.com" > /dev/null 2>&1
			else 
				echo "[SFD] SSL-Certificate: Fallback to Certificate in SSL-Storage."
			fi		
        fi
    fi
    if command -v certbot >/dev/null 2>&1; then
		echo "[SFD] SSL-Certificate: Stopping Apache2 Service for certbot generation.";
		service apache2 stop > /dev/null 2>&1
        echo "[SFD] SSL-Certificate: Creating/Renewing Certificate if required."
		certbot certonly --standalone \
			--non-interactive \
			--agree-tos \
			--email "$sf_letsencrypt_email" \
			-d "$sf_letsencrypt_domain"
		if [ -f "/etc/letsencrypt/live/$sf_letsencrypt_domain/privkey.pem" ] && [ -f "/etc/letsencrypt/live/$sf_letsencrypt_domain/cert.pem" ]; then
			echo "[SFD] SSL-Certificate: LetsEncrypt Certificate Creation/Renewing successfull."
			echo "[SFD] SSL-Certificate: Linking Certificate to SSL-Storage."
			unlink /opt/sf_ssl/privkey.pem > /dev/null 2>&1
			unlink /opt/sf_ssl/cert.pem > /dev/null 2>&1
			ln -sf "/etc/letsencrypt/live/$sf_letsencrypt_domain/privkey.pem" /opt/sf_ssl/privkey.pem
			ln -sf "/etc/letsencrypt/live/$sf_letsencrypt_domain/cert.pem" /opt/sf_ssl/cert.pem
			CRON_JOB="0 0 */14 * * root certbot renew --quiet --renew-hook 'supervisorctl restart apache2' >> /var/log/letsencrypt/renew.log 2>&1"
			CRON_FILE="/etc/cron.d/certbot"
			if [ ! -f "$CRON_FILE" ]; then
				touch "$CRON_FILE"
			fi			
			grep -Fxq "$CRON_JOB" "$CRON_FILE" 2>/dev/null
			if [ $? -ne 0 ]; then
				echo "$CRON_JOB" >> "$CRON_FILE"
				echo "[SFD] SSL-Certificate: Cron job added successfully for user 'root'."
			else
				unlink "$CRON_FILE"
				echo "[SFD] SSL-Certificate: Cron job already exists. File has been removed."
				echo "$CRON_JOB" >> "$CRON_FILE"
				echo "[SFD] SSL-Certificate: Cron job added successfully for user 'root'."
			fi
			echo "[SFD] SSL-Certificate: Setup Chmod 0770 on: $CRON_FILE";
			chmod 0770 "$CRON_FILE"
			echo "[SFD] SSL-Certificate: Activate Cronjob File: $CRON_FILE";
			crontab "$CRON_FILE"	
		else
			echo "[SFD] SSL-Certificate: LetsEncrypt Certificate Creation/Renewing failed."
			echo "[SFD] SSL-Certificate: Fallback to Certificate in SSL-Storage."
		fi
    fi
fi

##
## Certificate Handling (without LetsEncrypt)
##
if [ "$sf_letsencrypt_enable" -eq 0 ]; then
    echo "[SFD] SSL-Certificate: LetsEncrypt Certificate creation is disabled."
	if [ ! -f "/opt/sf_ssl/privkey.pem" ] || [ ! -f "/opt/sf_ssl/cert.pem" ]; then
		echo "[SFD] SSL-Certificate: Certificate File cert.pem and privkey.pem NOT found in SSL-Storage."
		echo "[SFD] SSL-Certificate: Starting Custom Certificate Generation."
		unlink /opt/sf_ssl/privkey.pem > /dev/null 2>&1
		unlink /opt/sf_ssl/cert.pem > /dev/null 2>&1
		openssl req -x509 -nodes -days 7300 -newkey rsa:2048 \
		 -keyout /opt/sf_ssl/privkey.pem \
		 -out /opt/sf_ssl/cert.pem \
		 -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=example.com" > /dev/null 2>&1
	else
		echo "[SFD] SSL-Certificate: Certificate File cert.pem and privkey.pem found in SSL-Storage."
		echo "[SFD] SSL-Certificate: Skipping Custom Certificate Generation."
	fi
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Database Operations
##
echo "[SFD] MySQL: Starting database service and waiting 5 seconds.";
service mariadb start > /dev/null 2>&1
sleep 5
echo "[SFD] MySQL: Update Initial Environment MySQL Root Password."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$sf_db_pass';" > /dev/null 2>&1
echo "[SFD] MySQL: Create Initial MySQL Database if not exists."
mysql -u root -p"$sf_db_pass" -e "CREATE DATABASE IF NOT EXISTS '$sf_db_db';" > /dev/null 2>&1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Cronjob Initialization
##
echo "[SFD] Cronjob: Setup Chmod 0644 on: /etc/cron.d/certbot";
chmod 0644  "/etc/cron.d/certbot" > /dev/null 2>&1
echo "[SFD] Cronjob: Activate Cronjob File: /etc/cron.d/certbot";
crontab "/etc/cron.d/certbot" > /dev/null 2>&1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

##
## Service Shutdown
##
echo "[SFD] Services: Stopping MySQL Service to be started by supervisor.";
service mariadb stop > /dev/null 2>&1
echo "[SFD] Services: Waiting 5 Seconds.";
sleep 5
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	
##
## Execute the main CMD Dockerfile command passed to the container
##
echo "[SFD] Initialization: Finished Executing Entry Point."
echo "[SFD] Initialization: Starting Main Container Prompt.";
exec "$@"