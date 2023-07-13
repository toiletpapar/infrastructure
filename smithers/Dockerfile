FROM node:18

# Copy repo
COPY --from=repo . /smithers-server
WORKDIR /smithers-server

RUN npm install
RUN npm run build

# Copy credentials
COPY ./credentials/gcloud.json ./credentials/gcloud.json

ENV GOOGLE_APPLICATION_CREDENTIALS ./credentials/gcloud.json
ENV DB_SECRET_NAME production-psql

ENTRYPOINT ["npm", "run", "start"]