FROM circleci/ubuntu-server:trusty-latest

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
# You shouldn't change the line unless you understand the consequence
RUN echo 'exit 101' > /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
        && dpkg-divert --local --rename --add /sbin/initctl \
        && ln -s /bin/true /sbin/initctl

ADD circleci-install* /usr/local/bin/

ADD circleci-provision-scripts /opt/circleci-provision-scripts

RUN circleci-install-all

# When running in unprivileged containers, need to use CircleCI Docker fork
ARG TARGET_UNPRIVILEGED_LXC
RUN if [ "$TARGET_UNPRIVILEGED_LXC" = "true" ]; then circleci-install circleci_docker; fi

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

ADD Dockerfile /opt/circleci/Dockerfile

LABEL circleci.user="ubuntu"
