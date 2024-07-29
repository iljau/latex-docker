FROM ubuntu:24.04

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# base packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    tini \
    gosu \
    curl \
    ca-certificates \
    tar \
    unzip \
    gzip \
    time \
    htop \
    less \
    lsof \
    strace \
    procps \
    neovim \
    micro \
    ninja-build \
    texlive \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    lmodern \
    && echo "apt-get done" \
#    && rm -rf /var/lib/apt/lists/* \
    ;

##

RUN mkdir /app-build
RUN mkdir /app

##

WORKDIR /app
COPY . /app

ENTRYPOINT ["tini", "-g", "--"]
CMD ["bash"]