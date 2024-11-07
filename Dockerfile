# Stage 1: Builder
FROM ruby:3.2.0 AS builder

# Install build dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    curl \
    nodejs && \
    rm -rf /var/lib/apt/lists/*  # Remove package manager cache to reduce image size

# Set working directory
WORKDIR /myapp

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Clean up gem cache after installation
RUN rm -rf /usr/local/bundle/cache

# Copy application code and precompile assets
COPY . .
RUN bundle exec rake assets:precompile

# Stage 2: Final Runtime
FROM ruby:3.2.0-slim AS runtime

# Install only runtime dependencies for the final image
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    redis-server && \
    rm -rf /var/lib/apt/lists/*  # Clean up cache again to keep image small

# Set environment variables for PostgreSQL
ENV POSTGRES_USER=huzaifa \
    POSTGRES_PASSWORD=1234 \
    POSTGRES_DB_DEV=memee_dev \
    POSTGRES_DB_TEST=memee_test

# Set working directory
WORKDIR /myapp

# Copy necessary files from the builder stage
COPY --from=builder /myapp /myapp

# Expose the Rails app port
EXPOSE 3000

# Initialize databases on container start and start services
CMD service redis-server start && \
    (service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE $POSTGRES_DB_DEV OWNER $POSTGRES_USER;\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE $POSTGRES_DB_TEST OWNER $POSTGRES_USER;\"" && \
    bundle exec rails db:migrate) && \
    rails server -b 0.0.0.0
