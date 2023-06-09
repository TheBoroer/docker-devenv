FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"] 

# Prereqs
RUN apt-get update \
    && apt-get install -y --no-install-recommends git make vim nano htop ncdu software-properties-common build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# zsh: install
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"

# python: install py2/py3 + pip/pip3. Symlink python/pip
RUN add-apt-repository universe \
    && apt-get update \
    && apt-get install -y python2 python3.8 python3-pip
RUN rm -f /usr/bin/pip \
    && rm -f /usr/bin/python \
    && rm -f /usr/local/bin/pip \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && ln -s /usr/bin/pip3 /usr/local/bin/pip \
    && ln -s /usr/bin/python3.8 /usr/bin/python

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && python2 get-pip.py

# pipenv: install
RUN pip install pipenv

# pyenv: install
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv

# pyenv: setup zsh
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile && \
    echo 'eval "$(pyenv init — path) "' >> ~/.zprofile && \
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# pyenv: setup for bash
RUN echo -e 'if shopt -q login_shell; then' \
    '\n export PYENV_ROOT="$HOME/.pyenv"' \
    '\n export PATH="$PYENV_ROOT/bin:$PATH"' \
    '\n eval "$(pyenv init — path)"' \
    '\nfi' >> ~/.bashrc &&\
    echo -e 'if [ -z "$BASH_VERSION" ]; then'\
    '\n export PYENV_ROOT="$HOME/.pyenv"'\
    '\n export PATH="$PYENV_ROOT/bin:$PATH"'\
    '\n eval "$(pyenv init — path)"'\
    '\nfi' >>~/.profile && \
    echo 'if command -v pyenv >/dev/null; then eval "$(pyenv init -)"; fi' >> ~/.bashrc 

# nvm + node18 + yarn
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18
RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install --global yarn

# gcloud cli: install
RUN apt-get install -y apt-transport-https ca-certificates gnupg curl sudo
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
    && apt-get update -y \
    && apt-get install -y  google-cloud-cli google-cloud-cli-app-engine-python google-cloud-cli-app-engine-python-extras google-cloud-cli-cloud-run-proxy google-cloud-cli-datastore-emulator google-cloud-cli-firestore-emulator

# docker-ce-cli
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli
RUN ln -s "/var/run/docker-host.sock" "/var/run/docker.sock"