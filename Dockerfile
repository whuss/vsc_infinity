ARG VARIANT="3.6"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

# [Option] Install Node.js

ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"

# Create tumx configuration file
COPY tmux.conf /home/vscode/.tmux.conf
RUN chown vscode:vscode /home/vscode/.tmux.conf

# Update .bashrc
COPY bashrc /home/vscode
RUN cat /home/vscode/bashrc >> /home/vscode/.bashrc && rm /home/vscode/bashrc

# Install virtualenvwrapper
RUN pip3 --disable-pip-version-check --no-cache-dir install virtualenvwrapper

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git-lfs cmake libgl1-mesa-glx tmux ripgrep fd-find exa fzf

# Install global node packages
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g eslint" 2>&1

RUN pipx install poetry
