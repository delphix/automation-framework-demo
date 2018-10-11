pipeline {
    agent any
    environment {
      DAF = 'docker run -v ${PWD}:/daf/app --env-file ${PWD}/.env mcred/daf'
    }
    stages {
        stage('Get Payload from GitHub') {
            steps {
                script {
                    def scmVars = checkout scm
                    env.GIT_COMMIT = scmVars.GIT_COMMIT
                    env.GIT_BRANCH = scmVars.GIT_BRANCH
                }
                sh "cp ./src/main/resources/application.properties.example ./src/main/resources/application.properties"
            }
        }

        stage('Apply Infrastructure as Code Changes') {
            steps {
                dir ('terraform') {
                    sh  "terraform init -backend=true -input=false"
                    sh  "terraform workspace select production"
                }
                script {
                    if ("${env.GIT_BRANCH}" == "origin/develop") {
                        stage ('develop') {
                            dir ('terraform') {
                                sh  "terraform taint -module=dev_web_server null_resource.deploy_stack"
                            }
                        }
                    }
                    if ("${env.GIT_BRANCH}" == "origin/master") {
                        stage ('prod') {
                            dir ('terraform') {
                                sh  "terraform taint -module=prod_web_server null_resource.deploy_stack"
                            }
                        }
                    }
                }
                dir ('terraform') {
                    sh  "terraform plan -out=tfplan -input=false"
                    script {
                        timeout(time: 10, unit: 'MINUTES') {
                            input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
                        }
                    }
                }
                dir ('terraform') {
                    sh  "terraform apply -lock=false -input=false tfplan"
                }
            }
        }

        stage('Apply Database as Code Changes') {
            when {
                expression { "${env.GIT_BRANCH}" != "origin/master" }
            }
            steps {
                sh  "docker pull mcred/daf"
                writeFile file: 'payload.json', text: payload
                script {
                    withCredentials([string(credentialsId: 'delphix_engine', variable: 'engine'), string(credentialsId: 'delphix_user', variable: 'user'), string(credentialsId: 'delphix_pass', variable: 'pass')]) {
                        env.DELPHIX_ENGINE = engine
                        env.DELPHIX_USER = user
                        env.DELPHIX_PASS = pass
                    }
                }
                sh "echo GIT_COMMIT=$GIT_COMMIT > .env"
                sh "echo GIT_BRANCH=$GIT_BRANCH >> .env"
                sh "echo DELPHIX_ENGINE=$DELPHIX_ENGINE >> .env"
                sh "echo DELPHIX_USER=$DELPHIX_USER >> .env"
                sh "echo DELPHIX_PASS=$DELPHIX_PASS >> .env"
                sh "${DAF}"
            }
        }

        stage ('Apply Schema as Code Changes') {
            steps {
              script {
                try {
                    sh 'mvn liquibase:update'
                } catch (Exception e) {
                    sh "echo GIT_EVENT=build-failure >> .env"
                    sh "${DAF}"
                }
              }
            }
        }

        stage('Deploy Application Stack') {
            steps {
              dir ('terraform') {
                sh  "ansible-playbook deploy.yaml -vvv"
              }
            }
        }
    }
}
