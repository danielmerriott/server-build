#!/bin/bash
### ****************************************************************************
###
### Install and configure wordpress
###
### Assumes:
###  - mysql server installed 'somewhere'
###  - root user has password-less access to the mysql server
###  - wp-cli has been installed
###  - this script is bring run in the folder that will host wordpress
###
### Notes:
###  - defaults to using the site external IP as the wordpress url
###  - initial login credentials: wp-admin / admin123
###
### ****************************************************************************

# setup wordpress variables
CWD=`pwd`
CWD=`basename $CWD | tr [:upper:] [:lower:]`
WP_SQL_DB_NAME=${CWD}_`</dev/urandom tr -dc [:lower:][:digit:] | head -c3`'_wp'
WP_SQL_DB_USER='wp_'`</dev/urandom tr -dc [:lower:][:digit:] | head -c5`
#WP_SQL_DB_USER_PWD=`</dev/urandom tr -dc '[:alnum:]!{}[]!@£$%^&*():;<>,.~?' | head -c23`
WP_SQL_DB_USER_PWD=`</dev/urandom tr -dc '[:alnum:]' | head -c23`
WP_SQL_TABLE_PREFIX='wp_'`</dev/urandom tr -dc [:lower:][:digit:] | head -c4`'_'

# create the wordpress database & user
echo "create database ${WP_SQL_DB_NAME}; grant all privileges on ${WP_SQL_DB_NAME}.* to '${WP_SQL_DB_USER}' identified by '${WP_SQL_DB_USER_PWD}'; flush privileges; revoke grant option on ${WP_SQL_DB_NAME}.* from '${WP_SQL_DB_USER}'; flush privileges;" | sudo -H mysql

# download latest wordpress
wp core download
# setup wp-config.php
wp core config --dbhost=localhost:/var/run/mysqld/mysqld.sock --dbname=${WP_SQL_DB_NAME} --dbuser=${WP_SQL_DB_USER} --dbpass=${WP_SQL_DB_USER_PWD} --skip-check
# setup the database tables
wp core install


# deploy standard htaccess file
cat >./.htaccess <<EOL
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOL
sudo chown www-data:www-data .htaccess
sudo chmod 660 .htaccess

# deploy some wordpress defaults
wp option update timezone_string 'Pacific/Auckland'
wp option update start_of_week 1
wp option update date_format 'j M Y'
wp option update time_format 'H:i'
wp option update use_smilies 0
wp option update gzipcompression 1
wp option update blog_public 0
wp rewrite structure '/%postname%'

# deploy standard my plugin setup
wp plugin delete hello                            # remove hello dolly
wp plugin install jetpack                         # wordpress features
wp plugin install debug-bar                       # development tool
wp plugin install developer                       # development tool
wp plugin install log-deprecated-notices          # development tool
wp plugin install never-email-passwords           # security tool
wp plugin install wp-password-policy-manager      # security tool
#wp plugin install force-strong-passwords         # security tool - alt: enforce-strong-password
wp plugin install authy-two-factor-authentication # security tool
wp plugin install cloudflare                      # performance and security
wp plugin install use-google-libraries            # performance - use google's AJAX library
wp plugin install google-analytics-for-wordpress  # yoast google analytics
wp plugin install wordpress-seo                   # yoast wordpress seo
wp plugin install edit-flow                       # editorial flow
wp plugin install simple-blog-stats               # perishable press simple stats
wp plugin install simple-feed-stats               # perishable press simple stats

### removed:
#wp plugin install sumome                          # testing for now
#wp plugin install contact-form-7                  # contact forms
#wp plugin install mailchimp-for-wp                # mailchimp plugin
#wp plugin install ninja-forms                     # contact forms


#wp plugin install download-monitor                # download tools needed for email-before-download
#wp plugin install email-before-download           # get an email before giving access to a downloadable file

# woocommerce
# swipehq: https://www.swipehq.co.nz/pages/assets/uploads/checkout/plugins/WooCommerce_Swipe_HQ_Checkout_plugin_2.9.1.zip
# woodojo: http://woodojo.s3.amazonaws.com/downloads/woodojo/woodojo.zip
# woocommerce-multilingual    # for multi-currency shopping REQUIRES WMPL or;
# currency-converter-widget   # for multi-currency display
# projects-by-woothemes
# testimonials-by-woothemes
# our-team-by-woothemes
# features-by-woothemes
# woosidebars



# feedwordpress
# pressforward
# wysija-newsletters (mailpoet)
# w3-total-cache
# revisr (git control - check it out)

# also consider bitly or yourls, with url-shortener, or shortnit
# mint (analytics)