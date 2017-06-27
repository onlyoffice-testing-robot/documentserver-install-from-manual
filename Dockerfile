FROM ubuntu:16.04

MAINTAINER Pavel.Lobashov "shockwavenn@gmail.com"

RUN apt-get update && apt-get install -y curl sudo

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" | sudo tee -a /etc/apt/sources.list
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo bash -
RUN sudo apt-get update && sudo apt-get install -y postgresql
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE DATABASE onlyoffice;" && \
    sudo -u postgres psql -c "CREATE USER onlyoffice WITH password 'onlyoffice';" && \
    sudo -u postgres psql -c "GRANT ALL privileges ON DATABASE onlyoffice TO onlyoffice;"
RUN sudo apt-get update && sudo apt-get install -y redis-server
RUN sudo apt-get update && sudo apt-get install -y rabbitmq-server
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
RUN sudo echo "deb http://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
RUN echo onlyoffice-documentserver-integration onlyoffice/db-pwd select onlyoffice | sudo debconf-set-selections
RUN service postgresql start && \
    sudo apt-get update && sudo apt-get -y install onlyoffice-documentserver-integration
CMD service postgresql start && \
    service rabbitmq-server start && \
    service redis-server start && \
    service nginx start && \
    service supervisor start && \
    supervisorctl start onlyoffice-documentserver:example && \
    bash