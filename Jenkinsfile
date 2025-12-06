pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '5fbca519-17c9-47b1-be72-c36deea8a68e'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        stage('Run tests') {
            parallel {

                stage('Unit') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post{
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.56.1-noble'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install -D @playwright/test@1.56.1
                            npm install -g serve
                            serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post{
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli@20.1.1 -g
                    netlify --version
                    echo "Deploy to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod 
                    echo "tadam"
                '''
            }
        }
    }
}
