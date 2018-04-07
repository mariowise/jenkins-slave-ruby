FROM jenkinsci/ssh-slave:latest
MAINTAINER Mario López <mario@requies.cl>

COPY .ruby.bashrc /home/jenkins

# Install Ruby
RUN apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y \
        git \
        wget \
        build-essential \
        libssl-dev \
        libreadline-dev \
        ca-certificates \
        zlib1g-dev && \
    git clone https://github.com/rbenv/rbenv.git /home/jenkins/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /home/jenkins/.rbenv/plugins/ruby-build && \
    sed -i '/for examples/a . ~/.ruby.bashrc' /home/jenkins/.bashrc && \
    chown -R jenkins:jenkins /home/jenkins && \
    su - jenkins -c 'rbenv install 2.4.4' && \
    su - jenkins -c 'rbenv global 2.4.4' && \
    su - jenkins -c 'gem install bundler' && \
    su - jenkins -c 'ln -s /home/jenkins/.rbenv/versions/2.4.4 /home/jenkins/.rbenv/versions/2.4' && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin