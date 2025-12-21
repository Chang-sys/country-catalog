# Stage 1: Development
FROM node:20-alpine AS development
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
EXPOSE 5173
CMD ["yarn", "dev", "--host", "0.0.0.0"]

# Stage 2: Build
FROM development AS build
RUN yarn build

# Stage 3: Production
FROM nginx:alpine AS production
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
