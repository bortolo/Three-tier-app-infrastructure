pipeline {
    agent any

    environment {
        ARM_SUBSCRIPTION_ID="de2dd9f0-a856-4177-b9f8-9fe12d786b1a"
        ARM_CLIENT_ID="f152ae7e-5da0-49ca-97dc-8d2e16617e85"
        ARM_CLIENT_SECRET="7ec68b63-7f52-4980-88f5-17b780cfbfc8"
        ARM_TENANT_ID="7ea682b6-6e2a-4f9a-b4f4-9bfff0782f62"

        TF_WORKSPACE = "/Users/andreabortolossi/Documents/Documents – Andrea’s MacBook Pro/Coding projects/Three-tier-app-infrastructure/terraform_main" //Sets the Terraform Workspace
        AB_WORKSPACE = "/Users/andreabortolossi/Documents/Documents – Andrea’s MacBook Pro/Coding projects/Three-tier-app-infrastructure/ansible-playbooks" //Sets the Ansible Workspace
        AB_SECRET_FILE = "/Users/andreabortolossi/Documents/Documents – Andrea’s MacBook Pro/Coding projects/Secrets/ansible_vault_password"
    }

   tools {
      // Install the Maven version configured as "M3" and add it to the path.
      maven 'Maven 3.3.9'
      jdk 'jdk8'
   }

   stages {
      stage('Build') {
         steps {
            echo "*** BUILD TODOLIST APP WITH MAVEN ***"
            echo "DOWNLOAD GITREPO"
            git "https://github.com/bortolo/javawebapp.git"
            echo "CREATING .WAR PACKAGE"
            sh "mvn clean package"
            echo "*** END MAVEN ***"
         }

      }

     stage('Create resources') {
         steps {
             dir("${env.TF_WORKSPACE}"){
                    echo "*** CREATING RESOURCES WITH TERRAFORM ***"
                    echo "INIT"
                    sh "terraform init -input=false"
                    echo "PLAN"
                    sh "terraform plan -var-file='terraform.tfvars' -out=tfplan -input=false"
                    echo "APPLY"
                    sh "terraform apply -input=false tfplan"
                    echo "*** END TERRAFORM ***"
             }
         }

      }

           stage('Deploy') {
         steps {
             dir("${env.AB_WORKSPACE}"){
                    echo "*** CONFIGURING RESOURCES WITH ANSIBLE ***"
                    sh "ansible-playbook --vault-id "${env.AB_SECRET_FILE}" -i ./myazure_rm.yml deploy-master-local-dev.yml -l tag_environment_management"
                    echo "*** END ANSIBLE ***"
             }

         }

      }
   }
}
