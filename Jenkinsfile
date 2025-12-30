pipeline {
    agent any

    environment {
        // NETLIFY_SITE_ID = '5fbca519-17c9-47b1-be72-c36deea8a68e'
        // NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.2.$BUILD_ID"
        //"${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}"
        AWS_DEFAULT_REGION = 'eu-north-1'
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

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli:latest'
                    args '-u root --entrypoint=""'
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        yum install -y jq
                        LATEST_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq ".taskDefinition.revision")
                        echo "Latest revision: $LATEST_REVISION"
                        aws ecs update-service --cluster LrnJenkins-Cluster-Prod1 --service LearnJenkinsApp-TaskDefinition-Prod-service-7plzbgcf --task-definition LearnJenkinsApp-TaskDefinition-Prod:$LATEST_REVISION
                        aws ecs wait services-stable --cluster LrnJenkins-Cluster-Prod1 --services LearnJenkinsApp-TaskDefinition-Prod-service-7plzbgcf 
                    '''
                }
                
            }
        }

        // stage('Run tests') {
        //     parallel {

        //         stage('Unit') {
        //             agent {
        //                 docker {
        //                     image 'node:18-alpine'
        //                     reuseNode true
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                     test -f build/index.html
        //                     npm test
        //                 '''
        //             }
        //             post{
        //                 always {
        //                     junit 'jest-results/junit.xml'
        //                 }
        //             }
        //         }
        //         stage('E2E') {
        //             agent {
        //                 docker {
        //                     image 'my-playwright:latest'
        //                     reuseNode true
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                     npm install -D @playwright/test@1.56.1
        //                     serve -s build &
        //                     npx playwright test --reporter=html
                            
        //                 '''
        //             }
        //             post{
        //                 always {
        //                     junit 'jest-results/junit.xml'
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('Staging E2E') {
        //     agent {
        //         docker {
        //             image 'my-playwright:latest'
        //             reuseNode true
        //         }
        //     }

        //     environment {
        //         CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
        //     }

        //     steps {
        //         sh '''
        //             netlify --version
        //             echo "Deploy to staging. Site ID: $NETLIFY_SITE_ID"
        //             netlify status
        //             netlify deploy --dir=build --json > deploy-output.json
        //             CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-output.json)
        //             npx playwright test  --reporter=html
        //         '''
        //     }

        //     post {
        //         always {
        //             publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
        //         }
        //     }
        // }
        
        // stage('Prod - Deploy & E2E') {
        //     agent {
        //         docker {
        //             image 'my-playwright:latest'
        //             reuseNode true
        //         }
        //     }

        //     environment {
        //         CI_ENVIRONMENT_URL = 'https://rysic.netlify.app'
        //     }

        //     steps {
        //         sh '''
        //             netlify --version
        //             echo "Deploy to production. Site ID: $NETLIFY_SITE_ID"
        //             netlify status
        //             netlify deploy --dir=build --prod 
        //             echo "tadam"
        //             npx playwright test  --reporter=html
        //         '''
        //     }

        //     post {
        //         always {
        //             publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
        //         }
        //     }
        // }
        
    }
}
