FROM nginx:1.26

RUN apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs

# Configure nginx
COPY ./nginx.conf /etc/nginx/nginx.conf

# Copy repo
COPY --from=repo . /smithers-expo
WORKDIR /smithers-expo

RUN npm install
RUN npm run build:web
RUN cp -rf dist/. /usr/share/nginx/html

# CMD [nginx-debug, '-g', 'daemon off;']