FROM public.ecr.aws/compose-x/aws-rds-ca as certbuild

FROM public.ecr.aws/amazoncorretto/amazoncorretto:17 as certimport
COPY --from=certbuild /var/opt/aws-rds.jks /var/opt/aws-rds.jks
RUN keytool -importkeystore -srckeystore /var/opt/aws-rds.jks -cacerts -srcstorepass changeit -deststorepass changeit

FROM certimport
# .. Install your application here
RUN yum update -y --security --exclude=kernel* --exclude=*corretto*
