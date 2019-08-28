# Convenience Dockerfile to make it easy to replicate the Travis build locally.
# Build this using `docker build`, then run it to get a shell.
#
# From the container shell, run the `updateRepo.sh` script. This will execute
# the project update process, but will not commit the changes. You can inspect
# what the script has done by looking in the /project/current/<branch name> dirs.
#
FROM swift:5.0.2 AS base

# Fix python directories in base image
RUN if [ -d "/usr/lib/python2.7/site-packages" ]; then \
  mv /usr/lib/python2.7/site-packages/* /usr/lib/python2.7/dist-packages \
    && rmdir /usr/lib/python2.7/site-packages \
    && ln -s dist-packages /usr/lib/python2.7/site-packages \
  ; fi

# Install dependencies (vim included for convenience)
# Install Node 10 (our version of Yeoman doesn't support Node 12) and generator dependencies
RUN apt-get update \
  && apt-get install -y libssl-dev libcurl4-openssl-dev curl vim \
  && curl -sLO https://deb.nodesource.com/setup_10.x \
  && bash ./setup_10.x \
  && rm ./setup_10.x \
  && apt-get install -y nodejs pandoc rsync

# Become a regular user
RUN useradd -u 1000 kitura \
  && mkdir -p /home/kitura \
  && chown -R kitura: /home/kitura
USER kitura

# Install generator and dependencies
RUN npm config set prefix /home/kitura \
  && npm install -g yo generator-swiftserver markdown-pdf

# Add NPM locations to path
ENV PATH=/home/kitura/bin:$PATH
ENV LD_LIBRARY_PATH=/home/kitura/lib:$LD_LIBRARY_PATH

# Copy generator-swiftserver-projects into image`
COPY --chown=kitura:kitura . /project
WORKDIR /project


#
# Test project generation
#
FROM base AS test

# Test project generation
RUN ./generateProject.sh

# Test generated project can be built
WORKDIR /project/Generator-Swiftserver-Projects
# Set the swift version to match this Dockerfile
# Use Package-Builder to build the project and run the tests
RUN echo "5.0.2" > .swift-version \
  && Package-Builder/build-package.sh -projectDir .


#
# Build image ready for executing updateRepo script
#
FROM base AS run

# Prepare to run the updateRepo script.
WORKDIR /project
CMD echo "Edit ./updateRepo.sh to replace <my-org> with your Github fork, then run it." && /bin/bash
