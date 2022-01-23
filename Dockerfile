FROM debian:11

ENV GO_VERSION 1.17.6

RUN apt-get update && apt-get install -y \
    git wget tmux nano procps links unzip curl \
    python3 python3-venv python3-wheel \
    php-cli php-curl php-xml ca-certificates \
    shellcheck silversearcher-ag locales openssh-client clang-format \ 
    rsync libssl-dev gettext build-essential bison flex libfl-dev \
    --no-install-recommends && rm -r /var/lib/apt/lists/* && \
    cd /tmp && \
    wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz && \
    rm go$GO_VERSION.linux-amd64.tar.gz && \
    curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    cd /opt && \
    git clone https://github.com/phacility/arcanist.git && \
    git clone https://github.com/vhbit/clang-format-linter.git && \
    git clone https://devcentral.nasqueron.org/source/shellcheck-linter.git && \
    wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && \
    wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh && \
    ln -s /opt/arcanist/bin/arc /usr/local/bin/arc && \
    ln -s /opt/config/gitconfig /root/.gitconfig && \
    ln -s /opt/config/arcrc /root/.arcrc
  
COPY files /

VOLUME ["/opt/config", "/opt/workspace"]
WORKDIR /opt/workspace

CMD bash
