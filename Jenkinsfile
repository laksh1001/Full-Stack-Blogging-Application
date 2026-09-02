pipeline { 
    agent any
    
    tools {
        maven 'maven3'
        jdk 'jdk21'
    }

    stages {
        
        stage('Compile') {
            steps {
            sh  "mvn compile"
            }
        }
        
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        
        stage('Package') {
            steps {
                sh "mvn package"
            }
        }
    }
}
