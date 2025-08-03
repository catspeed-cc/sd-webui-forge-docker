FROM nvidia/cuda:12.8.1-base-ubuntu22.04

# we do not want interactive anything
ENV DEBIAN_FRONTEND=noninteractive

# dummy to hold timestamp during build to bust the cache
# the lines probably were not cached, but we leave for debug anyways
# pretty much nothing caches and the build takes long
# especially the "exporting image" and "exporting layers" steps.
ARG DUMMY=

# Install system deps
RUN apt-get update && apt-get install -y \
    git wget nano curl htop gcc g++ libgl1 libglib2.0-0 python3 python3.10-venv python3-dev libcudnn8=8.9.2.26-1+cuda12.1 libcudnn8-dev=8.9.2.26-1+cuda12.1 && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade system jeez
RUN apt-get upgrade -y && apt-get dist-upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install the latest pip directly using get-pip.py
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py

# Install rustup without modifying profile files
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Add to PATH
ENV PATH="/root/.cargo/bin:/root/.rustup/bin:${PATH}"

# Force rustup to use 1.70.0 globally
ENV RUSTUP_TOOLCHAIN=1.70.0

# Suppress common harmless warnings in production
# Does not affect errors or app-level logging
# Also exists in webui-docker.sh
ENV PYTHONWARNINGS="ignore::FutureWarning,ignore::DeprecationWarning"

# Install and set default toolchain
RUN rustup install 1.70.0 && rustup default 1.70.0

# Create a global venv at /opt/venv
ENV VENV_PATH=/opt/venv
RUN python3 -m venv $VENV_PATH

# Add the venv's bin directory to PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Upgrade pip inside the venv
RUN pip install --upgrade pip

# Optional: make venv available to all users
RUN chmod -R 755 $VENV_PATH

# Verify
RUN echo "Cache bust: $DUMMY AFTER:" && rustc --version

# DEBUG - you need to add ```--progress=plain --build-arg DUMMY=$(date +%s)``` to your docker build cmd
RUN echo "Cache bust: $DUMMY AFTER INSTALL:" && rustc --version
RUN echo "Cache bust: $DUMMY AFTER INSTALL:" && which python3 && which pip3
RUN echo "Cache bust: $DUMMY AFTER INSTALL:" && python3 --version
RUN echo "Cache bust: $DUMMY AFTER INSTALL:" && pip3 --version

WORKDIR /app

# fix to our small issue ... We need this baked in, whether it is updated or not
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge webui

# copy the docker initialization script
COPY webui-docker.sh /app/webui-docker.sh
RUN chmod +x /app/webui-docker.sh

# copy the sauces
RUN mkdir /app/sauces
COPY secretsauce.sh /app/sauces
RUN chmod +x /app/sauces/secretsauce.sh
# end user calls this script via `docker-reinstall-container-deps.sh`

# Ensure APT cache is cleaned! (image size concerns)
RUN apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*   

#
## Startup SD WebUI Forge (very last)
#

EXPOSE 7860
CMD ["/app/start-webui.sh"]
# END OF FILE
