pipeline {
    agent any

    environment {
        // Environment variables
        REPO_URL = 'https://github.com/wamique00786/wesalvatore.git'
        DOCKER_IMAGE = 'wamique00786/wesalvatore'
      //  DOCKER_USER = 'wamique00786' // Replace with actual Docker Hub username
       // DOCKER_PASSWORD = credentials('dockerhub') // Replace with actual Docker Hub password
        CONTAINER_NAME = 'wesalvatore'
        DOCKER_BUILDKIT = '0' // Enable BuildKit
        TIMESTAMP = new Date().format("yyyyMMddHHmmss")
    }

    stages {
        // stage('Clone Repo') {
        //     steps {
        //         // Clone the repository
        //         sh "git clone -b main ${REPO_URL}"
        //     }
        // }
        
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
                script{
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
                sh "docker run -d  --restart=always --name ${CONTAINER_NAME} -p 80:8000 ${DOCKER_IMAGE}:latest"
            }
        }
    }
}

        /*
        stage('Production Deployment') {
            steps {
                // Pull the latest image and deploy it
                sh '''
                echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USER} --password-stdin
                docker pull ${DOCKER_IMAGE}:latest
                docker run -d --rm --restart=always --name ${CONTAINER_NAME} -p 80:8000 ${DOCKER_IMAGE}:latest
                '''
            }
        }
        */
    }
}
