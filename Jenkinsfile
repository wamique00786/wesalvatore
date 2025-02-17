pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/wamique00786/wesalvatore.git'
        DOCKER_IMAGE = 'wamique00786/wesalvatore'
        CONTAINER_NAME = 'wesalvatore'
        DOCKER_BUILDKIT = '0'
        TIMESTAMP = new Date().format("yyyyMMddHHmmss")
    }

    stages {
        stage('Build') {
            steps {
                sh '''
                DOCKER_BUILDKIT=0 docker build -t ${DOCKER_IMAGE}:${TIMESTAMP} .
                docker tag ${DOCKER_IMAGE}:${TIMESTAMP} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Pushing artifact') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
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
                        sh '''
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker pull ${DOCKER_IMAGE}:latest
                        '''

                        def containerExists = sh(script: "docker ps -a -q -f name=${CONTAINER_NAME}", returnStdout: true).trim()

                        if (containerExists) {
                            echo 'Stopping and removing existing container...'
                            sh "docker stop ${CONTAINER_NAME} || true"
                            sh "docker rm ${CONTAINER_NAME} || true"
                        } else {
                            echo 'No existing container to stop. Skipping removal process...'
                        }

                        echo 'Starting new container...'
                        sh "docker run -d --restart=always --name ${CONTAINER_NAME} -p 8000:8000 ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
    }
}
