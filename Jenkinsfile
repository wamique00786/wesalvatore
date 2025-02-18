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
                sudo docker build -t ${DOCKER_IMAGE}:${TIMESTAMP} .
                sudo docker tag ${DOCKER_IMAGE}:${TIMESTAMP} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Pushing artifact') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        echo "${DOCKER_PASSWORD}" | sudo docker login -u "${DOCKER_USER}" --password-stdin
                        sudo docker push ${DOCKER_IMAGE}:latest
                        sudo docker push ${DOCKER_IMAGE}:${TIMESTAMP}
                        '''
                    }
                }
            }
        }

        stage('UAT Deployment') {
            steps {
                script {
                    sh '''
                    if [ -z "$(sudo docker network ls -q -f name=wesalvatore_network)" ]; then
                        echo 'Creating Docker network...'
                        sudo docker network create wesalvatore_network
                    else
                        echo 'Network already exists. Skipping creation...'
                    fi

                    def containerExists = sh(script: "sudo docker ps -a -q -f name=${CONTAINER_NAME}", returnStdout: true).trim()

                    if (containerExists) {
                        echo 'Stopping and removing existing container...'
                        sudo docker stop ${CONTAINER_NAME} || true
                        sudo docker rm ${CONTAINER_NAME} || true
                    } else {
                        echo 'No existing container to stop. Skipping removal process...'
                    }

                    echo 'Starting new container...'
                    sudo docker run -d --restart=always --name ${CONTAINER_NAME} --network wesalvatore_network -p 8000:8000 ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }
}
