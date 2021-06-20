#Dockerfile for RubyOnRails

#Get Docker Image of Ruby
FROM ruby:2.7.3

# install rails dependencies
RUN apt-get clean all && apt-get update -qq && apt-get install -y build-essential libpq-dev \
    curl gnupg2 apt-utils default-libmysqlclient-dev git libcurl3-dev cmake \
    libssl-dev pkg-config openssl imagemagick file nodejs yarn

# Create App Directory
RUN mkdir /WebOpsBlog
WORKDIR /WebOpsBlog

# Copy the Gemfile and Gemfile.lock from app root directory into the /WebOpsBlog/ folder in the docker container
COPY Gemfile Gemfile.lock ./


# Run bundle install to install gems inside the gemfile
RUN bundle install

# Copy the whole app
COPY . .

# Run Server to Run The Whole Application
EXPOSE  3000

# Run Some Command to Configure Database and Sidekiq
ENTRYPOINT ["sh", "./config/docker/startup.sh"]