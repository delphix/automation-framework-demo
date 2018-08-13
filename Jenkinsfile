pipeline {
    agent any
    environment {
        TERRAFORM = 'docker run --network host -w /app -v ${HOME}/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh -v `pwd`:/app hashicorp/terraform:light'
    }
    stages {
        stage('checkout repo') {
            steps {
                script {
                    def scmVars = checkout scm
                    env.GIT_COMMIT = scmVars.GIT_COMMIT
                    GIT_COMMIT = scmVars.GIT_COMMIT
                    env.GIT_BRANCH = scmVars.GIT_BRANCH
                    GIT_BRANCH = scmVars.GIT_BRANCH
                }
                writeFile file: 'payload.json', text: payload
                sh "printenv"
            }
        }
        stage('pull latest light terraform image') {
            steps {
                sh  "docker pull hashicorp/terraform:light"
            }
        }
        stage('init') {
            steps {
                dir ('terraform') {
                    sh  "${TERRAFORM} init -backend=true -input=false"
                }
            }
        }
        stage('workspace') {
            steps {
                dir ('terraform') {
                    sh  "${TERRAFORM} workspace select production"
                }
            }
        }
        stage('plan') {
            steps {
                dir ('terraform') {
                    sh  "${TERRAFORM} plan -out=tfplan -input=false"
                    script {
                        timeout(time: 10, unit: 'MINUTES') {
                            input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
                        }
                    }
                }
            }
        }
        stage('apply') {
            steps {
                dir ('terraform') {
                    sh  "${TERRAFORM} apply -lock=false -input=false tfplan"
                }
            }
        }
    }
}
