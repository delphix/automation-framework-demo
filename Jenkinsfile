pipeline {
    agent any
    stages {
        stage('checkout repo') {
            steps {
                script {
                    def scmVars = checkout scm
                    env.GIT_COMMIT = scmVars.GIT_COMMIT
                    env.GIT_BRANCH = scmVars.GIT_BRANCH
                }
                sh "cp ./src/main/resources/application.properties.example ./src/main/resources/application.properties"
            }
        }

        stage('init terraform backend') {
            steps {
              dir ('terraform') {
                sh  "terraform init -backend=true -input=false"
                sh  "terraform workspace select production"
              }
            }
        }

        stage ('taint application environment') {
            steps {
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
            }
        }

        stage('plan environment changes') {
            steps {
              dir ('terraform') {
                sh  "terraform plan -out=tfplan -input=false"
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
                    }
                }
              }
            }
        }

        stage('apply environment changes') {
            steps {
              dir ('terraform') {
                sh  "terraform apply -lock=false -input=false tfplan"
              }
            }
        }

        stage('run delphix automation framework') {
            when {
                expression { "${env.GIT_BRANCH}" != "origin/master" }
            }
            steps {
                writeFile file: 'payload.json', text: payload
                script {
                    withCredentials([string(credentialsId: 'delphix_engine', variable: 'engine'), string(credentialsId: 'delphix_user', variable: 'user'), string(credentialsId: 'delphix_pass', variable: 'pass')]) {
                        env.DELPHIX_ENGINE = engine
                        env.DELPHIX_USER = user
                        env.DELPHIX_PASS = pass
                    }
                }
                sh "java -jar daf.jar"
            }
        }

        stage ('migrate schema') {
            steps {
                sh 'mvn liquibase:update'
            }
        }

        stage('deploy application') {
            steps {
              dir ('terraform') {
                sh  "ansible-playbook deploy.yaml -vvv"
              }
            }
        }
    }
}
