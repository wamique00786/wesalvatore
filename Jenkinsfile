pipeline {
    agent any

    environment {
        // Environment variables
        REPO_URL = 'https://github.com/wamique00786/wesalvatore.git'
        DOCKER_IMAGE = 'wamique00786/wesalvatore'
        CONTAINER_NAME = 'wesalvator'
        DOCKER_BUILDKIT = '0' // Enable BuildKit
        TIMESTAMP = new Date().format("yyyyMMddHHmmss")
    }

    stages {
        stage('Build') {
            steps {
                // Build Docker image with timestamp and latest tags
                sh '''
                DOCKER_BUILDKIT=0  docker build -t ${DOCKER_IMAGE}:${TIMESTAMP} .
                docker tag ${DOCKER_IMAGE}:${TIMESTAMP} ${DOCKER_IMAGE}:latest
                '''
            }
        }
        
        stage('Pushing artifact') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        echo "${DOCKER_USER}"
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:${TIMESTAMP}
                        '''
                    }
                }
            }
        }
        
        stage('UAT Deployment') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        // Login to Docker Hub
                        sh '''
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker pull ${DOCKER_IMAGE}:latest
                        '''
                        
                        // Check if the network 'wesalvator' exists
                        def networkExists = sh(script: "docker network ls --filter name=wesalvatore -q", returnStdout: true).trim()

                        // If the network doesn't exist, create it
                        if (!networkExists) {
                            echo 'Network "wesalvatore" not found. Creating new network...'
                            sh 'docker network create wesalvatore'
                        } else {
                            echo 'Network "wesalvatore" already exists.'
                        }

                        // Check if the container is running, stop and remove it if it exists
                        def containerExists = sh(
                            script: "docker ps -q -f name=${CONTAINER_NAME}",
                            returnStdout: true
                        ).trim()

                        if (containerExists) {
                            echo 'Stopping and removing existing container...'
                            sh "docker stop ${CONTAINER_NAME}"
                            sh "docker rm ${CONTAINER_NAME}"
                        } else {
                            echo 'No existing container to stop.'
                        }

                        // Run the new container
                        echo 'Starting new container...'
                        sh "docker run -d --restart=always --name ${CONTAINER_NAME} -p 8000:8000 --network wesalvatore ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
    }
}
