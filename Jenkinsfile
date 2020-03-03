@Library('CraftingIT-Library') _ 

pipeline {
	agent { label 'RELEASE' }
    triggers { cron('H */12 * * * ') }
    options { disableConcurrentBuilds() }
	stages{
        stage("Deploy") {  
            when { branch 'master'
            not  { triggeredBy 'SCMTrigger' } }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: '5f8da65a-5203-408b-b2cf-df6865c089b2', usernameVariable: 'username', passwordVariable: 'password')]){
                        sh './.ci/updater.sh'
                    }
                }
            }
        }
    }
    post {
	    always {    
            script {
                step ([$class: 'WsCleanup'])
            }
        }
    }
}
