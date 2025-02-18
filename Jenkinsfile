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
                docker build -t ${DOCKER_IMAGE}:${TIMESTAMP} .
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
                    sh '''
                    if [ -z "$(docker network ls -q -f name=wesalvatore_network)" ]; then
                        echo 'Creating Docker network...'
                        docker network create wesalvatore_network
                    else
                        echo 'Network already exists. Skipping creation...'
                    fi

                    def containerExists = sh(script: "docker ps -a -q -f name=${CONTAINER_NAME}", returnStdout: true).trim()

                    if (containerExists) {
                        echo 'Stopping and removing existing container...'
                         docker stop ${CONTAINER_NAME} || true
                         docker rm ${CONTAINER_NAME} || true
                    } else {
                        echo 'No existing container to stop. Skipping removal process...'
                    }

                    echo 'Starting new container...'
                     docker run -d --restart=always --name ${CONTAINER_NAME} --network wesalvatore_network -p 8000:8000 ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }
}
