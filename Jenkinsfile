pipeline {
  agent { label 'docker-maven-trivy' }
  tools {
    maven 'maven3'
  }
  environment {
    SONAR_IP = '172.31.37.14'
    ECR_REGISTRY = '661676948454.dkr.ecr.ap-south-1.amazonaws.com'
    IMAGE_REPO = "${ECR_REGISTRY}/devsecops_ci_cd_pipeline_prod_project"
  }
  stages {
    stage('Trivy FS Scan') {
      steps {
        sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL .'
      }
    }
    stage('Build & Sonar') {
      steps {
        withCredentials([string(credentialsId: 'SonarQube-Token', variable: 'SONAR_TOKEN')]) {
          sh 'mvn clean verify sonar:sonar \
              -Dsonar.projectKey=DevSecOps-CI-CD-Pipeline-Prod-Project \
              -Dsonar.host.url="http://${SONAR_IP}:9000" \
              -Dsonar.token="${SONAR_TOKEN}" \
              -Dsonar.qualitygate.wait=true'
        }
      }
    }
    stage('ECR Login') {
      steps {
        sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY}'
      }
    }
    stage('Build Docker Image') {
      steps {
        sh 'export DOCKER_BUILDKIT=0 && docker build --platform linux/amd64 -t "$IMAGE_REPO:$BUILD_NUMBER" -t "$IMAGE_REPO:latest" .'
      }
    }
    stage('Trivy Image Scan') {
        environment {
            // ${WORKSPACE} is always writable by the current Jenkins build agent
            TRIVY_CACHE_DIR = "${WORKSPACE}/.trivycache"
            TMPDIR          = "${WORKSPACE}/.tmp"
        }
        steps {
            sh '''
                mkdir -p ${TRIVY_CACHE_DIR} ${TMPDIR}
                trivy image --exit-code 1 --severity HIGH,CRITICAL "$IMAGE_REPO:$BUILD_NUMBER"
            '''
       
        }
      }
      stage('Push Image to ECR') {
        steps {
          sh 'docker push "$IMAGE_REPO:$BUILD_NUMBER"'
          sh 'docker push "$IMAGE_REPO:latest"'
        }
      }
      stage('Update Deployment') {
        steps {
          sh 'sed -i "s|image:.*|image: $IMAGE_REPO:$BUILD_NUMBER|g" deploy-svc.yaml'
        }
      }
    }
  }