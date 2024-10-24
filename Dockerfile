# Stage 1: Build the Remix App
FROM node:18 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the Remix app for production
RUN npm run build

# Stage 2: Create production image with the build
FROM node:18-alpine AS runner

# Set working directory for the production app
WORKDIR /app

# Copy the built app from the builder stage
COPY --from=builder /app/build ./build
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json /app/package-lock.json ./

# Install only production dependencies
RUN npm ci --only=production

# Expose the port the app runs on (default 3000)
EXPOSE 3000

# Run the Remix app
CMD ["npm", "run", "start"]
