# Dockerfile
# Use a Node 16 image.
FROM node:16-alpine   

# Define a working directory              
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy all source code
COPY . .

# Port for the application runs.
EXPOSE 8080

# Start command.
CMD ["npm", "start"]
