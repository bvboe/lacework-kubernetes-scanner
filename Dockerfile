FROM docker:latest
ADD https://github.com/lacework/lacework-vulnerability-scanner/releases/download/v0.2.1/lw-scanner-linux-amd64 /usr/local/bin/lw-scanner
RUN chmod 755 /usr/local/bin/lw-scanner
ADD https://github.com/lacework/go-sdk/releases/download/v0.19.0/lacework-cli-linux-386.tar.gz /tmp
RUN tar xf /tmp/lacework-cli-linux-386.tar.gz
COPY src/ /scanner/
CMD /scanner/scanner-daemon.sh
