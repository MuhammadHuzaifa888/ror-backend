# Uses the official Ruby image with the specified version
FROM ruby:3.2.0

# Install necessary dependencies
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    build-essential \
    curl \
    redis-server

# Install rbenv (Ruby Version Manager)
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

# Set up Ruby version using rbenv
ENV PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"
RUN rbenv install 3.2.0 && rbenv global 3.2.0

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

# Expose the Rails app port
EXPOSE 3000

# Start Redis and Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
