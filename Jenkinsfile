pipeline {
    agent any
    environment {
      DAF = 'docker run -v ${PWD}:/daf/app --env-file ${PWD}/.env delphix/automation-framework'
      DATICAL_PIPELINE = 'pipeline1'
      APPNAME = 'PATIENTS'
      PROJ_DDB="ddb"
      PROJ_SQL="app_src"
      APP_GITURL="git@localhost:/var/lib/jenkins/app_repo.git"
      DATICAL_GITURL="git@localhost:/var/lib/jenkins/datical"
      DATICAL_PROJECT_KEY="PATIENTS"
      SHORT_BRANCH = "default"
      TARGET_ENV = "default"
      TARGET_WEB = "default"
      DATICAL_COMMIT = "false"
      DATAPOD = ""
      DELPHIXPY_EXAMPLES_DIR="/opt/delphixpy-examples"
      LAST_STAGE=""
    }
    stages {
        stage('Prepare Environment'){
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                    SHORT_BRANCH = "${GIT_BRANCH}"
                    GIT_BRANCH = "origin/${GIT_BRANCH}"
                    sh "echo ${GIT_BRANCH}"
                    
                    if ("${GIT_BRANCH}" == "origin/master") {
                        TARGET_ENV = "QA"
                        TARGET_WEB = "testweb"
                        REPL = "/opt/datical/master/DaticalDB/repl"
                        DATAPOD = "Test"
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
                        DATAPOD = "Develop"
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
                expression { return DATICAL_COMMIT == "false" || GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production'}
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
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
                expression { return DATICAL_COMMIT == "false" || GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production'}
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
                dir ('ansible') {
                    sh  "ansible-playbook deploy.yaml -e delphix_pass=${DELPHIX_ADMIN_PASS} -e git_branch=${GIT_BRANCH} -e git_commit=${env.GIT_COMMIT} -e sdlc_env=${TARGET_ENV} --tags \"build\" --limit ${TARGET_WEB}"
                }
            }
        }

        stage('Refresh Data Pod') {
            when {
                expression {
                    return (GIT_BRANCH != "origin/production" && DATICAL_COMMIT == "false") || GIT_BRANCH == 'origin/master' 
                    }
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                    refresh = true
                    startMillis = System.currentTimeMillis()
                    timeoutMillis = 30000

                    try { 
                    timeout(time: timeoutMillis, unit: 'MILLISECONDS') {
                    input(
                        id: 'refresh', message: 'Proceed with Refresh', parameters: [
                        [$class: 'BooleanParameterDefinition', defaultValue: true, 
                        description: '', name: 'Abort continues without refresh']
                        ])
                    } 
                    } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                        cause = e.causes.get(0)
                        endMillis = System.currentTimeMillis()
                        if (cause.getUser().toString() != 'SYSTEM') {
                            refresh = false
                            echo "Refresh skipped."
                        } else {
                                if (endMillis - startMillis >= timeoutMillis) {
                                echo "Approval timed out. Continuing with refresh."
                            } else {
                                echo "Something weird happened"
                            }
                        }
                    }
                    if ( refresh == true ) {
                        sh "cat .env"
                        sh "${DAF}"
                    } else {
                        echo "User chose to skip data refresh"
                    }
                }
            }
        }

        stage('Package and Test SQL Changes') {
            when {
                expression {
                    return GIT_BRANCH != 'origin/master' && GIT_BRANCH != 'origin/production' && DATICAL_COMMIT == "false"
                    }
            }
			steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
                dir ("${PROJ_DDB}"){
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

        stage('Forecast Database Changes') {
            when {
                expression { return DATICAL_COMMIT == "false" || GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production' }
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
                dir ("${PROJ_DDB}"){
                    sh """
                        { set +x; } 2>/dev/null       
                        echo ==== Running - hammer version ====
                        hammer show version

                        # invoke Datical DB's Forecaster
                        echo ==== Running Forecast ====
                        echo hammer forecast ${TARGET_ENV} --labels=\"${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}\" --pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY}
                        hammer forecast ${TARGET_ENV} --labels=\"${DATICAL_PIPELINE},${APPNAME}-${BUILD_NUMBER}\" --pipeline=${DATICAL_PIPELINE} --projectKey=${DATICAL_PROJECT_KEY}
                        echo =====FINISHED====
                    """
                } 
            }
        }

        stage('Deploy Database Changes') {
            when {
                expression { return DATICAL_COMMIT == "false" || GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production'}
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
                dir ("${PROJ_DDB}"){					
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
        stage('Deploy Application Stack') {
            when {
                expression { return DATICAL_COMMIT == "false"|| GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production' }
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
                dir ('ansible') {
                sh  "ansible-playbook deploy.yaml -e git_branch=${GIT_BRANCH} -e sdlc_env=${TARGET_ENV} --tags \"deploy\" --limit ${TARGET_WEB}"
                }
            }
        }
        stage('Automated Testing') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                script {
                    LAST_STAGE = env.STAGE_NAME
                }
                sh  "/var/lib/jenkins/daf_tests"
                junit 'build/reports/*.xml'
            }
        }
    }
    post {
        always {
            script {
                if (DATICAL_COMMIT == "false" || GIT_BRANCH == 'origin/master' || GIT_BRANCH == 'origin/production') {
                    archiveArtifacts '**/daticaldb.log, **/Reports/**, **/Logs/**, **/Snapshots/**'
                }
                if (currentBuild.result == 'FAILURE' || currentBuild.result == 'UNSTABLE' ){
                    //Open a bug in Bugzilla and bookmark the datapod with the information
                    sh """
                        { set +x; } 2>/dev/null
                        #Create a bug and grab the id
                        echo +++Creating BUG+++
                        CONSOLE=\$(curl http://localhost:8080//job/PatientsPipeline/job/${SHORT_BRANCH}/${env.BUILD_NUMBER}/consoleText)
                        BUG=\$(/usr/local/bin/bz_create_bug.py --hostname localhost --login admin --password password --summary \"${SHORT_BRANCH} ${env.BUILD_NUMBER} ${LAST_STAGE}\" --description \"\${CONSOLE}\${DAFOUT}\")
                        echo +++\${BUG}+++

                        #Create a bookmark on the datapod with the information, if a non-prod build
                        if [[ -n "${DATAPOD}" ]]; then
                            echo +++Bookmarking Datapod+++
                            ${DELPHIXPY_EXAMPLES_DIR}/dx_jetstream_container.py --template "Patients" --container "${DATAPOD}" \
                                --operation bookmark --bookmark_name "${env.BUILD_TAG}" --bookmark_tags "\${BUG},${env.GIT_COMMIT}" \
                                --bookmark_shared true --conf ${DELPHIXPY_EXAMPLES_DIR}/dxtools.conf
                        fi
                    """
                    //Run DAF if the .env file exists; otherwise data was not involved
                    sh """ 
                        { set +x; } 2>/dev/null
                        if [[ -f .env ]]; then
                            echo +++Running DAF+++
                            echo -e "\nGIT_EVENT=build-failure" >> .env
                            ${DAF}
                        fi
                    """
                }
            }
       }
    }
}
 