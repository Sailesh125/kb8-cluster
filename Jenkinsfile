#!/usr/bin/env groovy

pipeline {

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }

    agent {
                label "docker"
            }


    stages {
      stage("Prerequisite Check") {

        stage('Initialize') {

             steps {

                script {

                    sleep 60
                    def BUILD_BRANCH = env.BRANCH_NAME
                    def BUILD_BRANCH_TYPE = null
                    def BUILD_BRANCH_TASK = null
                    def BUILD_SHA1 = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    def BUILD_TAG = sh(script: "git tag -l --points-at HEAD", returnStdout: true).trim()
                    def BUILD_TYPE = null
                    def BUILD_VERSION = null
                    def matcher = BUILD_BRANCH =~ /(.*)\/(.*)/
                    def TAG_VERSION = BUILD_TAG.split( '-' )

                    env.BUILD_BRANCH = BUILD_BRANCH
                    env.BUILD_BRANCH_TYPE = BUILD_BRANCH_TYPE
                    env.BUILD_BRANCH_TASK = BUILD_BRANCH_TASK
                    env.BUILD_SHA1 = BUILD_SHA1
                    env.BUILD_TAG = BUILD_TAG
                    env.BUILD_TYPE = BUILD_TYPE
                    env.BUILD_VERSION = BUILD_VERSION										
        }	

        stage('Build + Docker') {

                when {
                expression {
                    return "${BUILD_BRANCH_TYPE}" != "stagingref" && "${BUILD_BRANCH_TYPE}" != "master";
                }
            }

            steps {
                script {
                        container('docker') {

                        stage('Build Docker Image') {

                                            withDockerRegistry([credentialsId: 'ap-south-1:id_ofawscrediantial', url: "340866772701.dkr.ecr.ap-south-1.amazonaws.com"]) {
                                            sh """
                                              echo "Docker creation : In Progress"
                                              echo "Build Docker : In Progress"
                                              mvn  docker:build -B -X -Drevision=$BUILD_TAG
                                              mvn  docker:tag -B -X -Dimage=$JOB_NAME -DnewName=340866772701.dkr.ecr.ap-south-1.amazonaws.com/makemyplan:$TAG_NAME -Drevision=$BUILD_TAG
                                              echo "Build Docker : Completed"
                                             """
                                            }
                                          }

                                        stage('Upload Image to ECR') {

                                            withDockerRegistry([credentialsId: 'ap-south-1:id_ofawscrediantial', url: "340866772701.dkr.ecr.ap-south-1.amazonaws.com"])
                                                                                                {
                                            sh """
                                                 echo "Push Docker image to ECR : In Progress"
                                                 docker push 340866772701.dkr.ecr.ap-south-1.amazonaws.com/makemyplan:$TAG_NAME
                                                 echo "Push Docker image to ECR : Completed"
                                               """
                                                }                                                                                                            
                                        }
                                    }
                                }
                            }
						}

       
        stage('Production Deployment') {
            when {
                expression {
                    return "${BUILD_BRANCH_TYPE}" != "stagingref" && "${BUILD_BRANCH_TYPE}" != "master";
                }
            }

            steps {

                container('kubectl') {
                        sh 'which kubectl'
                        script {

                        sh """

                            echo "Deploying on production environment : In Progress"
                            sed -i 's/<version>/${TAG_NAME}/g' ./kubernetes/production/06-deployment.yaml
                            kubectl apply -f ./kubernetes/production --namespace 'prod'
                            echo "Deploying on production environment : Completed"
                        fi

                        sleep 90

                        """
                        }
                    }
                }
            }

    post
            {
               success {
                    message: "*SUCCESS:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}. \n More info at: ${env.BUILD_URL}")
                    emailext subject: "SUCCESS: Jenkins Java Build ${env.JOB_NAME} [${env.BUILD_NUMBER}]", to: 'email2satyam@', body: """
                               <p><font color="green">BUILD SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</font></p>
                               <p><font color="green">Deployed Docker Image TAG: '${BUILD_TAG}' :</font></p>
              <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>
                                """
                }
                failure {

                                        message: "*FAILED:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}. \n More info at: ${env.BUILD_URL}")
                    emailext subject: "FAILED: Jenkins Java Build ${env.JOB_NAME} [${env.BUILD_NUMBER}]", to: 'email2satyam@',
                            body: """
                                <p><font color="red"> BUILD FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]    Docker Image TAG: '${BUILD_TAG}''</font></p>
                                <p><font color="red">Deployed Docker Image TAG: '${BUILD_TAG}' :</font></p>
                                <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>
                                """
                }
            }

   }
 }
