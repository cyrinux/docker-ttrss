FROM debian:stretch-slim
MAINTAINER PR <code@ongoing.today>

## Install tools and libraries
RUN apt-get update -yqq && \
    mkdir -p /usr/share/man/man1 && \
    mkdir -p /usr/share/man/man7 && \
    apt-get install -yqq --no-install-recommends \
        apache2 \
        ca-certificates \
        git \
        php \
        libapache2-mod-php \
        libxml2-utils \
        php-cli \
        php-curl \
        php-gd \
        php-intl \
        php-json \
        php-pgsql \
        php-mbstring \
        php-mcrypt \
        php-opcache \
        php-xml \
        postgresql-client \
        supervisor \
        tidy && \
# Checkout TT-RSS and plugins
    git clone https://git.tt-rss.org/fox/tt-rss.git /var/www/html/ttrss && \
    git clone https://github.com/reuteras/ttrss_plugin-af_feedmod.git /var/www/html/ttrss/plugins.local/af_feedmod && \
    git clone https://github.com/fastcat/tt-rss-ff-xmllint /tmp/ff_xmllint && \
    git clone https://github.com/joshp23/ttrss-to-wallabag-v2.git /tmp/ttrss-to-wallabag-v2 && \
    git clone https://github.com/jangernert/FeedReader /tmp/feedreader && \
    mv /tmp/ff_xmllint/ff_xmllint /var/www/html/ttrss/plugins.local/ && \
    mv /tmp/ttrss-to-wallabag-v2/wallabag_v2 /var/www/html/ttrss/plugins.local/ && \
    mv /tmp/feedreader/data/tt-rss-feedreader-plugin/api_feedreader /var/www/html/ttrss/plugins.local/ && \
# Clean up
    rm -rf /var/www/html/ttrss/.git && \
    rm -rf /var/www/html/ttrss/plugins.local/af_feedmod/.git && \
    rm -rf /tmp/feedreader && \
    rm -rf /tmp/ttrss-to-wallabag-v2 && \
    apt-get remove -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /usr/share/doc /usr/local/share/man /var/cache/debconf/*-old && \
    rm -rf /usr/share/man

# Copy files to docker
COPY ttrss.conf /etc/apache2/sites-available/ttrss.conf
COPY config.php /var/www/html/ttrss/config.php
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

# Configure Apache
RUN chmod 644 /etc/apache2/sites-available/ttrss.conf && \
    a2ensite ttrss.conf && \
    a2dissite 000-default && \
    a2dissite default-ssl && \
    chmod +x /entrypoint.sh && \
    chown -R www-data:www-data /var/www/html/ttrss

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
