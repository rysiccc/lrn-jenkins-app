pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '5fbca519-17c9-47b1-be72-c36deea8a68e'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.2.$BUILD_ID"
        //"${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}"
    }

    stages {

        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli:latest'
                    args '--entrypoint=""'
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        echo "1" > text.txt
                        aws s3 cp text.txt s3://lrn-jenkins-rysic/index.html
                        aws s3 ls s3://lrn-jenkins-rysic/
                    '''
                }
                
            }
        }

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
                            image 'my-playwright:latest'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install -D @playwright/test@1.56.1
                            serve -s build &
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

        stage('Staging E2E') {
            agent {
                docker {
                    image 'my-playwright:latest'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
            }

            steps {
                sh '''
                    netlify --version
                    echo "Deploy to staging. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-output.json)
                    npx playwright test  --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
        
        stage('Prod - Deploy & E2E') {
            agent {
                docker {
                    image 'my-playwright:latest'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://rysic.netlify.app'
            }

            steps {
                sh '''
                    netlify --version
                    echo "Deploy to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod 
                    echo "tadam"
                    npx playwright test  --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
        
    }
}
