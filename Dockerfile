FROM openjdk:8u222-jdk
WORKDIR /app
COPY yb-cdc-connector.jar /app
ENTRYPOINT [ "java", "-jar", "yb-cdc-connector.jar", "--table_name", "postgres.users", "--log_only", "--master_addrs", "yb-master:7100" ]