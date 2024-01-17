ARG JAVA_VERSION=11
ARG BASE_IMAGE=public.ecr.aws/ews-network/amazoncorretto:${JAVA_VERSION}


FROM $BASE_IMAGE as certbuild
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem /etc/ssl/certs/rds-combined-ca-bundle.pem
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem /etc/ssl/certs/aws-global.pem
RUN yum install perl openssl gawk -y
RUN awk 'split_after == 1 {n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1}{print > "rds-ca-" n ".pem"}' < /etc/ssl/certs/rds-combined-ca-bundle.pem; \
    for CERT in rds-ca-*; do alias=$(openssl x509 -noout -text -in $CERT | perl -ne 'next unless /Subject:/; s/.*(CN=|CN = )//; print') ; echo "Importing $alias" ; keytool -import -file ${CERT} -alias "${alias}" -storepass changeit -keystore /var/opt/aws-rds.jks -noprompt ; done; \
    awk 'split_after == 1 {n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1}{print > "rds-ca-" n ".pem"}' < /etc/ssl/certs/aws-global.pem ;\
    for CERT in rds-ca-*; do alias=$(openssl x509 -noout -text -in $CERT | perl -ne 'next unless /Subject:/; s/.*(CN=|CN = )//; print') ; echo "Importing $alias" ; keytool -importcert -file ${CERT} -alias "${alias}" -storepass changeit -keystore /var/opt/aws-rds.jks -noprompt ; done;

FROM busybox
WORKDIR /var/opt/
COPY --from=certbuild /var/opt/aws-rds.jks /var/opt/aws-rds.jks
