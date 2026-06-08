# syntax=docker/dockerfile:1

# ── Stage 1: build ────────────────────────────────────────────────────────────
# Install compile-time dependencies (build-essential, libsqlite3-dev) and bundle
# the gem set. This stage is discarded after the build — its ~200 MB of tooling
# never reaches the final image.
FROM ruby:3.3.6-slim AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy manifests first so Docker can cache the bundle layer independently of
# application source changes — a gem-only change skips the source copy.
COPY Gemfile Gemfile.lock ./

# Install the exact Bundler version the lock file was generated with.
# Without this, the newer Bundler shipped in the base image sees the BUNDLED WITH
# mismatch and exits with code 5 (GemNotFound) before installing anything.
RUN gem install bundler -v "$(grep -A 1 'BUNDLED WITH' Gemfile.lock | tail -1 | tr -d ' ')"

# Install production gems only; development/test tooling stays off the image.
# sqlite3 2.x bundles its own SQLite3 source and compiles it by default (the 1.x flag
# --with-sqlite3-use-system-libraries is silently ignored in 2.x). --enable-system-libraries
# is the correct 2.x flag; it tells extconf.rb to link against libsqlite3-dev instead,
# skipping the ~30s bundled compile.
RUN bundle config set --local without "development test" && \
    bundle config set --local build.sqlite3 "--enable-system-libraries" && \
    bundle install --jobs 4 --retry 3

COPY . .

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
# Fresh base image — no compiler, no headers. Only the SQLite3 shared library
# is needed at runtime (~1 MB vs the ~15 MB dev package above).
FROM ruby:3.3.6-slim AS runtime

# slim is glibc-based (not musl/Alpine), which avoids native-gem ABI issues
# with the sqlite3 gem's compiled .so.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Pre-compiled gems from the build stage — no compiler required here.
COPY --from=build /usr/local/bundle /usr/local/bundle
# Application source.
COPY --from=build /app /app

# Ensure the db mount point directory exists. movies.db is NOT baked into the
# image — it is bind-mounted at runtime so that migration writes and any other
# updates survive container restarts.
RUN mkdir -p db

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 4000

ENV RAILS_ENV=production
ENV PORT=4000
ENV RAILS_LOG_TO_STDOUT=1
# In a real deployment SECRET_KEY_BASE would be injected from a secrets manager
# (AWS Secrets Manager, GCP Secret Manager, Vault, etc.) and never committed to
# source. Generate a real value with: bundle exec rails secret
ENV SECRET_KEY_BASE=replace_this_with_the_output_of_bundle_exec_rails_secret

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
