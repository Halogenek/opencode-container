FROM debian:trixie-slim

# Install system dependencies from packages.txt
COPY packages.txt /tmp/packages.txt
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && grep -v '^#' /tmp/packages.txt | grep -v '^$' | xargs apt-get install -y \
    && apt-get clean

# Create a user with placeholder UID and GID that will be updated at runtime
RUN groupadd -g 1000 opencode && \
    useradd -m -u 1000 -g opencode -s /bin/bash opencode && \
    echo "opencode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/opencode && \
    chmod 0440 /etc/sudoers.d/opencode

# Copy and run secure installation script for OpenCode CLI
COPY opencode.config /app/opencode.config
COPY scripts/secure_opencode_install.sh /tmp/secure_opencode_install.sh
RUN chmod +x /tmp/secure_opencode_install.sh && \
    /tmp/secure_opencode_install.sh

COPY scripts/docker_scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/startup.sh"]
