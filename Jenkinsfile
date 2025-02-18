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
                        export DOCKER_CONFIG=/tmp/.docker
                        mkdir -p $DOCKER_CONFIG
                        echo "{ \\"auths\\": { \\"https://index.docker.io/v1/\\": { \\"auth\\": \\"$(echo -n ${DOCKER_USER}:${DOCKER_PASSWORD} | base64)\\" } } }" > $DOCKER_CONFIG/config.json
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

                    if [ ! -z "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
                        echo 'Stopping and removing existing container...'
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    fi

                    echo 'Starting new container...'
                    docker run -d --restart=always --name ${CONTAINER_NAME} --network wesalvatore_network -p 8000:8000 ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }
}
