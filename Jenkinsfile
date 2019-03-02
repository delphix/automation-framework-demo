pipeline {
    agent any
    environment {
      DAF = 'docker run -v ${PWD}:/daf/app --env-file ${PWD}/.env delphix/automation-framework'
      DATICAL_PIPELINE = 'pipeline1'
      APPNAME = 'PATIENTS'
      PROJ_DDB="ddb"
      PROJ_SQL="app_src"
      APP_GITURL="/var/lib/jenkins/app_repo.git"
      DATICAL_GITURL="/var/lib/jenkins/datical"
      DATICAL_PROJECT_KEY="PATIENTS"
      SHORT_BRANCH = "default"
      TARGET_ENV = "default"
      TARGET_WEB = "default"
      DATICAL_COMMIT = "false"
    }
    stages {
        stage('Prepare Environment'){
            steps {
                script {
                    // SHORT_BRANCH = sh(returnStdout: true, script: "echo ${GIT_BRANCH} | cut -d '/' -f2").trim()
                    SHORT_BRANCH = "${GIT_BRANCH}"
                    GIT_BRANCH = "origin/${GIT_BRANCH}"
                    sh "echo ${GIT_BRANCH}"
                    if ("${GIT_BRANCH}" == "origin/master") {
                        TARGET_ENV = "QA"
                        TARGET_WEB = "testweb"
                        REPL = "/opt/datical/master/DaticalDB/repl"
                    }
                    if ("${GIT_BRANCH}" == "origin/production") {
                        TARGET_ENV = "PROD"
                        TARGET_WEB = "prodweb"
                        REPL = "/opt/datical/production/DaticalDB/repl"
                    }
                    if ("${GIT_BRANCH}" != "origin/master" && "${GIT_BRANCH}" != "origin/production") {
                        TARGET_ENV = "DEV"
                        TARGET_WEB = "devweb"
                        REPL = "/opt/datical/develop/DaticalDB/repl"
                    }
                    DATICAL_COMMIT = sh(returnStdout: true, script: "git show -s --oneline ${GIT_COMMIT}| grep 'Datical automatic check-in' && echo 'true'|| echo 'false'").trim()
                    env.PATH = "${REPL}:${ORACLE_HOME}/bin:${PATH}"
                }
                sh "env"
                sh "git clean -ffdx"
                sh "echo $PATH"
            }
        }

        stage("Prepare Workspace") {
            when {
                expression { return DATICAL_COMMIT == "false" || (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')}
            }
            steps {
				checkout([
					$class: 'GitSCM', 
					branches: [[name: '*/master']], 
					doGenerateSubmoduleConfigurations: false, 
					extensions: [
					  [$class: 'RelativeTargetDirectory', relativeTargetDir: "${PROJ_DDB}"],
					  [$class: 'LocalBranch', localBranch: 'master']],
					submoduleCfg: [], 
					userRemoteConfigs: [[url: "${DATICAL_GITURL}"]]
				])
                dir ("${PROJ_DDB}"){
                    sh "git branch --set-upstream-to=origin/master master"
                }
                checkout([
                        $class: 'GitSCM', 
                        branches: [[name: "${SHORT_BRANCH}"]], 
                        doGenerateSubmoduleConfigurations: false, 
                        extensions: [
                        [$class: 'RelativeTargetDirectory', relativeTargetDir: "${PROJ_SQL}"], 
                        [$class: 'LocalBranch', localBranch: "${SHORT_BRANCH}"], 
                        [$class: 'UserIdentity', email: 'jenkins@company.com', name: 'jenkins']], 
                        submoduleCfg: [], 
                        userRemoteConfigs: [[url: "${APP_GITURL}"]]
                ])
                dir ("${PROJ_SQL}"){
                    sh "git branch --set-upstream-to=${GIT_BRANCH} ${SHORT_BRANCH} && git status"
                }
            }
        }

        stage('Compile Application') {
            when {
                expression { return DATICAL_COMMIT == "false" || (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')}
            }
            steps {
              dir ('ansible') {
                sh  "ansible-playbook deploy.yaml -e git_branch=${GIT_BRANCH} -e git_commit=${env.GIT_COMMIT} -e sdlc_env=${TARGET_ENV} --tags \"build\" --limit ${TARGET_WEB}"
                // sh "echo placeholder"
              }
            }
        }

        // stage('Update Masked Master') {
        //     when {
        //         expression {
        //             return GIT_BRANCH != "origin/production" && DATICAL_COMMIT == "false"
        //             }
        //     }
        //     steps {
        //         sh "/usr/local/bin/snap_prod_refresh_mm -c conf.txt"
        //     }
        // }

        stage('Refresh Data Pod') {
            when {
                expression {
                    return GIT_BRANCH != "origin/production" && DATICAL_COMMIT == "false"
                    }
            }
            steps {
                // sh "echo placeholder"
                sh  "docker pull delphix/automation-framework"
                sh "cat .env"
                sh "${DAF}"
            }
        }

        stage('Package and Test SQL Changes') {
            when {
                expression {
                    return GIT_BRANCH != 'origin/master' && GIT_BRANCH != 'origin/production' && DATICAL_COMMIT == "false"
                    }
            }
			steps {
                dir ("${PROJ_DDB}"){
                    withCredentials([usernamePassword(credentialsId: 'daticaladminacct', passwordVariable: 'DATICAL_PASSWORD', usernameVariable: 'DATICAL_USERNAME')]) {				
                        sh """
                        { set +x; } 2>/dev/null
                        echo
                        echo "==== Running - hammer version ===="
                        echo ${PATH}
                        echo ${REPL}
                        ls -lart ${REPL}
                        which hammer
                        hammer show version
                
                        # invoke Datical DB's Deployment Packager
                        echo "==== Running Deployment Packager ===="
                        echo "hammer groovy deployPackager.groovy pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY} scm=true labels=${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}"
                        hammer groovy deployPackager.groovy pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY} scm=true labels=${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}
                        """
                    }
                }
			} 
        }

        // stage('Create Database Code Artifact') {
        //     when {
        //         expression {
        //             return GIT_BRANCH != 'origin/master' && GIT_BRANCH != 'origin/production' && DATICAL_COMMIT == "false"
        //             }
        //     }
		// 	steps {
        //         dir ("${PROJ_DDB}"){
        //             sh """
        //                 { set +x; } 2>/dev/null
        //                 echo
        //                 echo "==== Creating ${APPNAME}-${BUILD_NUMBER}.zip ===="
        //                 zip -r ../../${APPNAME}-${BUILD_NUMBER}.zip . -x *.git* -x *Logs* -x *Reports* -x *Snapshots* -x *Profiles* -x .classpath -x .gitignore -x .metadata -x .project -x .reporttemplates -x *daticaldb*.log -x *datical.project* -x deployPackager.properties
    
        //                 echo
        //                 echo "=====FINISHED===="
        //             """
        //         }
        //     }
		// }

        // stage('Retrieve Database Code Artifact') {
        //     when {
        //         expression {
        //             return (GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production') && DATICAL_COMMIT == "false"
        //         }
        //     }
		// 	steps {
        //         sh """
        //             { set +x; } 2>/dev/null
        //             echo
        //             echo "==== Retrieving ${APPNAME}-${BUILD_NUMBER}.zip ===="
        //             unzip ../${APPNAME}-${BUILD_NUMBER}.zip
        //             """
        //     }
        // }

        stage('Forecast Database Changes') {
            when {
                expression { return DATICAL_COMMIT == "false" || (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')}
            }
            steps {
                dir ("${PROJ_DDB}"){
                    withCredentials([usernamePassword(credentialsId: 'daticaladminacct', passwordVariable: 'DATICAL_PASSWORD', usernameVariable: 'DATICAL_USERNAME')]) {						
                        sh """
                            { set +x; } 2>/dev/null       
                            echo ==== Running - hammer version ====
                            hammer show version

                            # invoke Datical DB's Deployment Packager
                            echo ==== Running Forecast ====
                            echo hammer forecast ${TARGET_ENV} --labels=\"${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}\" --pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY}
                            hammer forecast ${TARGET_ENV} --labels=\"${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}\" --pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY}
                            echo =====FINISHED====
                        """
                    }   
                } 
            }
        }

        stage('Deploy Database Changes') {
            when {
                expression { return DATICAL_COMMIT == "false" || (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')}
            }
            steps {
                dir ("${PROJ_DDB}"){
                    withCredentials([usernamePassword(credentialsId: 'daticaladminacct', passwordVariable: 'DATICAL_PASSWORD', usernameVariable: 'DATICAL_USERNAME')]) {						
                        sh """
                            { set +x; } 2>/dev/null
                            # invoke Datical DB's Deployment Packager
                            echo ==== Running Deploy ====
                            echo hammer deploy ${TARGET_ENV} --labels=\"${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}\" --pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY}
                            hammer deploy ${TARGET_ENV} --labels=\"${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}\" --pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY}
                            echo =====FINISHED====
                        """
                    }
                }	
            }
        } 

        // stage('Update Datical Server') {
        //     when {
        //         expression { return DATICAL_COMMIT == "false"|| (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')}
        //     }
        //     steps {
        //         dir ("${PROJ_DDB}"){
        //         withCredentials([usernamePassword(credentialsId: 'daticaladminacct', passwordVariable: 'DATICAL_PASSWORD', usernameVariable: 'DATICAL_USERNAME')]) {						
        //             sh """
        //                 { set +x; } 2>/dev/null
        //                 echo
        //                 echo ==== Update DMC5 ====
        //                 hammer status ${TARGET_ENV}
        //                 echo =====FINISHED====
        //             """
        //             }
        //         } 
        //     } 
        // } 	
        
        stage('Deploy Application Stack') {
            when {
                expression { return DATICAL_COMMIT == "false"|| (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')}
            }
            steps {
                dir ('ansible') {
                sh  "ansible-playbook deploy.yaml -e git_branch=${GIT_BRANCH} -e sdlc_env=${TARGET_ENV} --tags \"deploy\" --limit ${TARGET_WEB}"
                // sh "echo placeholder"
                }
            }
        }
    }
    post {
        failure {
            sh "echo GIT_EVENT=build-failure >> .env"
            sh "${DAF}"
        }
        always {
         // Jenkins Artifacts
            script {
                if (DATICAL_COMMIT == "false" || (GIT_BRANCH == 'origin/master' && GIT_BRANCH == 'origin/production')) {
                    archiveArtifacts '**/daticaldb.log, **/Reports/**, **/Logs/**, **/Snapshots/**'
                }
            }
       }
    }
}
