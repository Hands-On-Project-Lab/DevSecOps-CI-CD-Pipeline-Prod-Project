pipeline {
  agent { label 'docker-maven-trivy' }
  tools {
    maven 'maven3'
  }
  environment {
    SONAR_IP = '172.31.21.44'
  }
  stages {
    stage('Trivy FS Scan') {
      steps {
        sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL .'
      }
    }
    stage('Build & Sonar') {
      steps {
        withCredentials([string(credentialsId: 'sonarqube-token-new', variable: 'SONAR_TOKEN')]) {
          sh 'mvn clean verify sonar:sonar \
              -Dsonar.projectKey=DevSecOps-CI-CD-Pipeline-Prod-Project \
              -Dsonar.host.url="http://${SONAR_IP}:9000" \
              -Dsonar.token="${SONAR_TOKEN}" \
              -Dsonar.qualitygate.wait=true'
        }
      }
    }
  }
}