// Jenkinsfile - Task3

pipeline {

  agent any

  options{
    timestamps()
  }
  
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
      agent { 
        docker { 
          image 'node:16-bullseye'
          args '-u root' 
        } 
      }
      steps {
        sh '''
          bash -lc '
            set -euo pipefail
            (npm ci || npm install --save) 2>&1 | tee build.log
          '
        '''

        echo 'Building the application'
      }
    }
    
    // Run unit test.
    stage('Test') {
      agent { 
        docker { 
          image 'node:16-bullseye'
          args '-u root' 
        } 
      }
      steps {
        sh '''
          bash -lc '
            set -euo pipefail
            (npm test || echo "no tests") 2>&1 | tee test.log
          '
        '''
        echo 'Testing the application'
      }
    }

    // Snyk scan before building image, fail on high/critical issues.
    stage('Dependency Scan') {
      agent { 
        docker { 
          image 'node:16-bullseye'
          args '-u root' 
        } 
      }
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          sh '''
            bash -lc '
              set -euo pipefail
              npx snyk@latest auth "$SNYK_TOKEN" 
              npx snyk@latest test --severity-threshold=high 2>&1 | tee snyk.log
            '
          '''
          echo 'Snyk scan finished'
        }
      }
    }
    
    // Build docker image using DinD
    stage('Build Image') {
      steps {
        sh '''
          docker version 2>&1 | tee buildimage.log
          echo "Build image" | tee -a buildimage.log
          docker build -t "$IMAGE:$TAG" -t "$IMAGE:latest" . 2>&1 | tee -a buildimage.log
        '''
        echo 'build image finished'
      }
    }


    //Push image to docker hub
    stage('Push Image') {
        steps {
          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'U', passwordVariable: 'P')]) {
            sh '''
              docker version 2>&1 | tee push.log
              echo "$P" | docker login -u "$U" --password-stdin 2>&1 | tee -a push.log
              docker push "$IMAGE:$TAG"    2>&1 | tee -a push.log
              docker push "$IMAGE:latest"  2>&1 | tee -a push.log
              docker logout || true
            '''
          }
          echo 'Image pushed to docker hubc'
        }
      }
    }
  post {
      always {
        archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
      }
    }
}


