# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t treasure_hunt_tracker .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name treasure_hunt_tracker treasure_hunt_tracker

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install only runtime dependencies
RUN apt-get update && \
    dpkg --add-architecture amd64 &&  \
    apt-get install -y --no-install-recommends \
      postgresql-client \
      tzdata \
      bash \
      && rm -rf /var/lib/apt/lists/*

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

RUN apt-get update && \
      apt-get install -y --no-install-recommends curl && \
      curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
      apt-get install -y nodejs && \
      npm install -g npm@latest && \
      rm -rf /var/lib/apt/lists/*

# Install packages needed to build gems and node modules
RUN apt-get update && \
    dpkg --add-architecture amd64 &&  \
    apt-get install -y --no-install-recommends \
      build-essential \
      ruby-dev \
      libpq-dev \
      python3-pip \
      libssl-dev \
      pkgconf \
      && rm -rf /var/lib/apt/lists/*

# Install JavaScript dependencies
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN npm install -g yarn@$YARN_VERSION

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ \
           "${BUNDLE_PATH}/ruby/*/cache" \
           "${BUNDLE_PATH}/ruby/*/bundler/gems/*/.git" \
           "${BUNDLE_PATH}/ruby/*/extensions/*" \
           "${BUNDLE_PATH}/ruby/*/doc"

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN rm -rf node_modules && \
    rm -rf infra && \
    rm -rf log/* && \
    rm -rf tmp/*

# Remove build dependencies
RUN apt-get remove -y build-essential ruby-dev libpq-dev linux-headers-amd64 \
                     libssl-dev pkg-config make gcc \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
# Create a system group and user for Rails
RUN addgroup -S rails -g 1000 && \
    adduser -S rails -u 1000 -G rails -h /home/rails -s /bin/sh && \
    chown -R rails:rails db log storage tmp

# Switch to the new Rails user
USER rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
