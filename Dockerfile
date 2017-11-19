# Use a ubuntu image built for arm
FROM armhfbuild/ubuntu:14.04

# Apt-get install without question
ARG         DEBIAN_FRONTEND=noninteractive

# Install security updates and required packages
RUN         apt-get update && \
            apt-get -y upgrade && \
            apt-get -y install -q \
                build-essential \
                git \
                subversion \
                python-dev \
                libffi-dev \
                libssl-dev \
                python-pip \
                curl && \
            rm -rf /var/lib/apt/lists/*  

RUN pip install pip --upgrade
USER root
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Install buidbot
RUN addgroup --system buildbot
RUN adduser buildbot --system --ingroup buildbot --shell /bin/bash
COPY requirements.txt /home/buildbot
RUN pip install -r /home/buildbot/requirements.txt
RUN pip install 'buildbot[bundle]' 

# Start buildbot worker
EXPOSE 8010
USER buildbot
WORKDIR /home/buildbot
RUN buildbot-worker create-worker . 172.17.0.1 npm-docker-worker root
ENTRYPOINT ["/usr/local/bin/buildbot-worker"]
CMD ["start", "--nodaemon"]
