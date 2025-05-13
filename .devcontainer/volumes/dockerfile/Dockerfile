FROM node:24-bookworm

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential

RUN npm install -g pnpm vite


COPY ./bashrc.sh /tmp/bashrc.sh
RUN bash /tmp/bashrc.sh && rm /tmp/bashrc.sh

CMD ["sleep", "infinity"]
