FROM node:18

# Copy repo
COPY --from=repo . /smithers-server
WORKDIR /smithers-server

# Copy credentials
COPY ./credentials/gcloud.json ./credentials/gcloud.json
COPY ./credentials/prodUsers.json ./credentials/prodUsers.json

RUN npm install
RUN npm run build

ENV GOOGLE_APPLICATION_CREDENTIALS ./credentials/gcloud.json
ENV DB_SECRET_NAME production-psql
ENV NODE_ENV production

ENTRYPOINT ["npm", "run", "start"]