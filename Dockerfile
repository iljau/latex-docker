FROM ubuntu:24.04

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV MAMBA_NO_BANNER=1

ARG MINIFORGE_VERSION="24.3.0-0"

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
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    && echo "apt-get done" \
#    && rm -rf /var/lib/apt/lists/* \
    ;


# create base conda environment using mambaforge
RUN set -x && \
    pwd && \
    MINIFORGE_FILENAME="Mambaforge-$(uname)-$(uname -m).sh" && \
    MINIFORGE_DOWNLOAD_URL="https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${MINIFORGE_FILENAME}" && \
    curl -L -o "Miniforge3.sh" "$MINIFORGE_DOWNLOAD_URL" && \
    bash "./Miniforge3.sh" -b -p /opt/mambaforge && \
    /opt/mambaforge/bin/python --version && \
    /opt/mambaforge/condabin/mamba clean --all && \
    rm "./Miniforge3.sh" && \
    echo "done";


# add base conda utils to path
ENV PATH="/opt/mambaforge/condabin:$PATH"

RUN set -x && \
    conda config --file /opt/mambaforge/.condarc --add envs_dirs /opt/envs;

RUN set -x && \
    mamba install conda-tree -n base && \
    mamba clean --all && \
    echo "done";

##

RUN mkdir /app-build
RUN mkdir /app

##

COPY environment.yml /app-build
#COPY environment-pinned-linux.yml /app-build/environment.yml

# create new conda environment named "main"
RUN set -x && \
    mamba env create -n main --file=/app-build/environment.yml && \
    /opt/envs/main/bin/python --version && \
    mamba clean --all && \
    echo "done";

RUN set -x && \
    conda env export -n main && \
    echo "done";




# "activate" "main" conda environment
ENV CONDA_PREFIX="/opt/envs/main"
ENV PATH="$CONDA_PREFIX/bin:$PATH"


RUN set -x && \
    conda env export -n main > /app-build/environment-final.yml && \
    cat /app-build/environment-final.yml && \
    echo "done";

RUN set -x && \
    /opt/mambaforge/bin/conda-tree -n main deptree --small > /app-build/deptree.txt && \
    cat /app-build/deptree.txt && \
    echo "done";

WORKDIR /app
COPY . /app

ENTRYPOINT ["tini", "-g", "--"]

#CMD ["/bin/bash"]
CMD ["bash"]
#CMD ["/app/run_app.sh"]
