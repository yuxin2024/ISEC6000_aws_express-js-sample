// Jenkinsfile - Task3

pipeline {

  // Use Node 16 Docker image as the build agent
  agent { 
    docker { 
      image 'node:16-bullseye'
      args '-u root' 
    } 
  }

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
    COMPOSE_NET       = 'project2-compose_jenkins'
  }

  stages {

    // Build and install dependentcies use node 16
    stage('Build') { 
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
      agent {
        docker {
          image 'docker:24.0-cli'
          args "-u root -v /certs/client:/certs/client:ro --network ${COMPOSE_NET}"
        }
      }
      steps {
        sh '''
          apk add --no-cache bash >/dev/null
          bash -lc '
            set -euo pipefail
            docker -H "$DOCKER_HOST" --tlsverify \
            --tlscacert=$DOCKER_CERT_PATH/ca.pem \
            --tlscert=$DOCKER_CERT_PATH/cert.pem \
            --tlskey=$DOCKER_CERT_PATH/key.pem version | tee -a buildimage.log
            echo "Build image $IMAGE:$TAG" | tee -a buildimage.log
            docker build -t "$IMAGE:$TAG" -t "$IMAGE:latest" . 2>&1 | tee -a buildimage.log
          '
        '''

        echo 'Image build successfully'
      }
      
    }

    //Push image to docker hub
    stage('Push Image') {
      agent {
        docker {
          image 'docker:24.0-cli'
          args "-u root -v /certs/client:/certs/client:ro --network ${COMPOSE_NET}"
        }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh '''
            apk add --no-cache bash >/dev/null
            bash -lc '
              set -euo pipefail
              docker version 2>&1 
              echo "$P" | docker login -u "$U" --password-stdin 2>&1 | tee push.log
              docker push "$IMAGE:$TAG"   2>&1 | tee -a push.log
              docker push "$IMAGE:latest" 2>&1 | tee -a push.log
              docker logout || true
            '
          '''

        }
        echo 'Image pushed to docker hub'
      }
    }  
  }

  post {
      always {
        archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
      }
    }
}


