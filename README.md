A very simple docker image/layer containing the JKS bundled with all the AWS RDS CAs


### Usage

```

FROM public.ecr.aws/compose-x/aws-rds-ca as certbuild
RUN file /var/opt/aws-rds.jks

FROM public.ecr.aws/amazoncorretto/amazoncorretto:17 as certimport
COPY --from=certbuild /var/opt/aws-rds.jks /var/opt/aws-rds.jks
RUN keytool -importkeystore -srckeystore /var/opt/aws-rds.jks -cacerts -srcstorepass changeit -deststorepass changeit

FROM certimport
# .. Install your application here

```
