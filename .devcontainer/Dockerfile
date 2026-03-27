FROM ruby:3.2.10-slim

# Toolchain required by native gems (e.g., prism via ruby-lsp) and Postgres client libs.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libyaml-dev \
      postgresql \
      postgresql-client \
      libpq-dev && \
    rm -rf /var/lib/apt/lists/*
