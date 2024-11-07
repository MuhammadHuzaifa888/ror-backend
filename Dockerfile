# Stage 1: Build stage
FROM node:14 AS build

# Set working directory for build stage
WORKDIR /usr/src/app

# Install dependencies first to leverage Docker cache
COPY package*.json ./
RUN npm install --production

# Copy the rest of the application files (excluding unnecessary files)
COPY . .

# Stage 2: Runtime stage
FROM node:14-slim

# Set the working directory for the runtime stage
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=build /usr/src/app /usr/src/app

# Expose the port for the application
EXPOSE 4000

# Start the application
CMD ["npm", "start"]
