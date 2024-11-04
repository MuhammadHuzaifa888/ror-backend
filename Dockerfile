FROM ruby:3.2.0

# Install necessary dependencies
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql \
    postgresql-contrib \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    build-essential \
    curl \
    redis-server

# Set environment variables for PostgreSQL
ENV POSTGRES_USER=huzaifa \
    POSTGRES_PASSWORD=1234 \
    POSTGRES_DB_DEV=memee_dev \
    POSTGRES_DB_TEST=memee_test

# Set up PostgreSQL user and databases
RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE $POSTGRES_DB_DEV OWNER $POSTGRES_USER;\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE $POSTGRES_DB_TEST OWNER $POSTGRES_USER;\"" && \
    service postgresql stop

# Enable and start Redis and PostgreSQL as background services
RUN echo "alias start_services='service postgresql start && service redis-server start'" >> ~/.bashrc

# Set working directory
WORKDIR /myapp

# Copy Gemfile and install gems
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler && bundle install

# Copy application code
COPY . /myapp

# Precompile assets (if using Rails with assets)
RUN bundle exec rake assets:precompile

# Run Rails migrations during build
RUN start_services && bundle exec rails db:migrate && service postgresql stop && service redis-server stop

# Expose the Rails app port
EXPOSE 3000

# Start PostgreSQL, Redis, and Rails server
CMD ["bash", "-c", "service postgresql start && service redis-server start && rails server -b 0.0.0.0"]
