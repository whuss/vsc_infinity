FROM rust:1.48 as builder

WORKDIR /src

RUN cargo install tokei bat ytop dutree procs \
    && cargo install -f --git https://github.com/jez/as-tree

FROM mcr.microsoft.com/vscode/devcontainers/python:0-3.6

# Install Node.js
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

# install starship
ADD https://starship.rs/install.sh install.sh
RUN chmod a+x install.sh && ./install.sh --yes && rm install.sh

# copy tools from builder stage
COPY --from=builder /usr/local/cargo/bin/tokei /usr/local/bin
COPY --from=builder /usr/local/cargo/bin/bat /usr/local/bin
COPY --from=builder /usr/local/cargo/bin/ytop /usr/local/bin
COPY --from=builder /usr/local/cargo/bin/dutree /usr/local/bin
COPY --from=builder /usr/local/cargo/bin/procs /usr/local/bin
COPY --from=builder /usr/local/cargo/bin/as-tree /usr/local/bin