pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
    
        stage ("terraform init") {
            steps {
                sh ("terraform init -reconfigure") 
            }
        }
        
        stage ("plan") {
            steps {
                sh ('terraform plan') 
            }
        }

        stage (" Action") {
            steps {
                echo "hello ADAM"
                echo "Terraform action is --> ${action}"
                sh ('terraform ${action} --auto-approve') 
                /* sh ('terraform apply -auto-approve') */
           }
        }
    }
}
