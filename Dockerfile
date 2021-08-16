FROM docker:latest
COPY src/ /scanner/
ADD https://github.com/lacework/lacework-vulnerability-scanner/releases/download/v0.1.3/lw-scanner-linux-amd64 /usr/local/bin/lw-scanner
RUN chmod 755 /usr/local/bin/lw-scanner
CMD /scanner/scanner-daemon.sh
