pipline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('access-key')
        AWS_SECRET_ACCESS_KEY = credentials('secret-key')


    }

    stage {
        stage('Init') {
            steps {
                sh 'terraform init'

            }
        }

        stage ('choose env') {
            steps {
                script {
                    if (env.GIT_BRANCH == 'origin/develop') {
                        sh 'terrform select dev'
                    }elif (env.GIT_BRANCH == 'origin/stage') {
                        sh 'terraform select stage'
                    }elif {env.GIT_BRANCH == 'origin/main'} {
                        sh 'terraform select prod' 
                    }
                }
                
            }
        }
        stage('plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Apply') {
            steps {
                sh 'terraform init'
            }
        }    

    }

}
