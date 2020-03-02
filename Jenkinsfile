@Library('CraftingIT-Library') _ 

pipeline {
	agent {
			label 'RELEASE'
			}
    triggers { cron('0 0 * * *'), 
               cron('12 0 * * *') }

	stages{
        stage("Deploy") {  
           withCredentials([usernamePassword(credentialsId: '5f8da65a-5203-408b-b2cf-df6865c089b2', usernameVariable: 'username', passwordVariable: 'password')]){
             sh '.ci/updater.sh'
           }
        }
    }
}
