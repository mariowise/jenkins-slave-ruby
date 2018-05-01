FROM openjdk:8-jdk

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-server \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd

WORKDIR "${JENKINS_AGENT_HOME}"

ADD setup-sshd /usr/local/bin/setup-sshd
RUN chmod a+x /usr/local/bin/setup-sshd

ADD .ruby.bashrc /home/jenkins/.ruby.bashrc

RUN apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y \
        git \
        wget \
        build-essential \
        libssl-dev \
        libreadline-dev \
        ca-certificates \
        python-pip \
        python-dev \
        zlib1g-dev \
        nano && \
    pip install awscli && \
    git clone https://github.com/rbenv/rbenv.git /home/jenkins/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /home/jenkins/.rbenv/plugins/ruby-build && \
    sed -i '/for examples/a . ~/.ruby.bashrc' /home/jenkins/.bashrc && \
    chown -R jenkins:jenkins /home/jenkins && \
    su - jenkins -c 'rbenv install 2.4.4' && \
    su - jenkins -c 'rbenv global 2.4.4' && \
    su - jenkins -c 'gem install bundler' && \
    su - jenkins -c 'ln -s /home/jenkins/.rbenv/versions/2.4.4 /home/jenkins/.rbenv/versions/2.4' && \
    su - jenkins -c 'mkdir -p ~/.aws' && \
    su - jenkins -c 'curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash' && \
    su - jenkins -c 'npm install -g yarn' && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

EXPOSE 22

ENTRYPOINT ["setup-sshd"]
