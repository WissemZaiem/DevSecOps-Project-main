# Set yarn network timeout and retry configuration
RUN yarn config set network-timeout 300000
RUN yarn config set registry https://registry.npmjs.org/

# Retry yarn install with better error handling
RUN for i in 1 2 3; do \
    yarn install --network-timeout 300000 && break || \
    (echo "Yarn install attempt $i failed, retrying..." && sleep 10); \
    done

COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]