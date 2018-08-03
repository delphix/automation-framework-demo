pipeline {
    agent any
    environment {
        TERRAFORM = 'docker run --network host -w /app -v ${HOME}/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh -v `pwd`:/app hashicorp/terraform:light'
    }
    stages {
        stage('checkout repo') {
            steps {
                checkout scm
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
