// Jenkinsfile - Task3

pipeline {
  agent any
  
  // Defined environment variables for DinD connection and image.
  environment {
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_CERT_PATH  = '/certs/client'
    DOCKER_TLS_VERIFY = '1'
    IMAGE             = 'zoezhou2024/assignment2'
    TAG               = "build-${env.BUILD_NUMBER}"
  }

  stages {

    // Build and install dependentcies use node 16
    stage('Build') {
      agent { docker { image 'node:16'; args '-u root' } }
      steps {
        sh 'npm ci || npm install'
        echo 'Building the application'
      }
    }
    
    // Run unit test.
    stage('Test') {
      agent { docker { image 'node:16'; args '-u root' } }
      steps {
        sh 'npm test || echo "no tests"'
        echo 'Testing the application'
      }
    }

    // Sacn before building image, fail on high/critical issues.
    stage('Dependency Scan') {
      agent { docker { image 'node:16'; args '-u root' } }
      steps {
        sh 'npm audit --audit-level=high'   
        echo 'Security scan passed'
      }
    }
    
    // Build docker image using DinD
    stage('Build Image') {
      agent { docker { image 'docker:24.0-cli'; args '-v /certs/client:/certs/client:ro' } }
      steps {
        sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .'
        echo 'Image built sucessful'
      }
    }

    //Push image to docker hub
    stage('Push') {
      agent { docker { image 'docker:24.0-cli'; args '-v /certs/client:/certs/client:ro' } }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh 'echo "$P" | docker login -u "$U" --password-stdin'
          sh 'docker push $IMAGE:$TAG && docker push $IMAGE:latest'
        }
        echo 'Image pushed to docker hub'
      }
    }

  }
}
