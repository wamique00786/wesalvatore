pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/wamique00786/wesalvator.git'
        DOCKER_IMAGE = 'wamique00786/wesalvator'
        CONTAINER_NAME = 'wesalvator'
        DOCKER_BUILDKIT = '0'
        TIMESTAMP = new Date().format("yyyyMMddHHmmss")
        
        // Database connection details (for the app to connect)
        DATABASE_HOST = credentials('DATABASE_HOST')
        DATABASE_USER = credentials('DATABASE_USER')
        DATABASE_PASSWORD = credentials('DATABASE_PASSWORD')
        DATABASE_NAME = credentials('DATABASE_NAME')
        SECRET_KEY = credentials('SECRET_KEY')
        
        // Django secret key
    }

    stages {
        stage('Git Clone') {
            steps {
                script {
                    // Clone the repository
                    echo "Cloning repository from ${REPO_URL}"
                    git branch: 'main', url: "${REPO_URL}"
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh '''
                    docker build -t ${DOCKER_IMAGE}:${TIMESTAMP} . 
                    docker tag ${DOCKER_IMAGE}:${TIMESTAMP} ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo "Pushing Docker image to Docker Hub..."
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
                    echo "Deploying application container..."
                    sh '''
                    NETWORK_EXISTS=$(docker network ls --format "{{.Name}}" | grep -w wesalvator_network || true)
                    if [ -z "$NETWORK_EXISTS" ]; then
                        echo 'Creating Docker network...'
                        docker network create wesalvator_network
                    else
                        echo 'Network already exists. Skipping creation...'
                    fi

                    # Check if the app container exists and remove it
                    if [ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
                        echo 'Stopping and removing existing app container...'
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    fi

                    echo 'Starting new app container...'
                    docker run -d --restart=always --name ${CONTAINER_NAME} --network wesalvator_network -p 8000:8000 \
                      -e DATABASE_HOST=${DATABASE_HOST} \
                      -e DATABASE_USER=${DATABASE_USER} \
                      -e DATABASE_PASSWORD=${DATABASE_PASSWORD} \
                      -e DATABASE_NAME=${DATABASE_NAME} \
                      -e SECRET_KEY=${SECRET_KEY} \
                      -e GDAL_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/libgdal.so \
                      -v static_volume:/app/staticfiles \
                      -v media_volume:/app/media \
                      ${DOCKER_IMAGE}:latest
                    docker system prune -a -f
                    '''
                }
            }
        }
    }
}
