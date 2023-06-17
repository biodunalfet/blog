# Choose a base image
FROM ubuntu:latest

# Install Hugo
ENV HUGO_VERSION 0.88.1
RUN apt-get update \
    && apt-get install -y curl \
    && curl -L -o /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
    && tar -xf /tmp/hugo.tar.gz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/hugo \
    && rm -rf /tmp/* \
    && apt-get remove -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the website source files
COPY . .

# Build the website
RUN hugo --minify

# Serve the website on port 80
CMD ["hugo", "server", "-t", "holy", "--bind=0.0.0.0", "--port=80", "--minify", "--disableFastRender", "--appendPort=false"]