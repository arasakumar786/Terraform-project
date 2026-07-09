pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Select environment')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    }

    environment {
        AWS_CREDS = credentials('aws-terraform-creds')   // Jenkins credential ID
        TF_DIR    = "environment/${params.ENV}"
        SLACK_CHANNEL = "#all-arasan"
    }

    options {
        timestamps()
        disableConcurrentBuilds()   // prevents two runs touching same state at once
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                    sh 'terraform fmt -check'
                }
            }
        }

        stage('Security Scan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'tfsec . || true'   // remove "|| true" once you want it to hard-fail builds
                }
            }
        }
        stage ('fetch secrets') {
            steps {
                script {
                    env.TF_VAR_db_password = sh(script: "aws ssm get-parameter --name /rds/${params.ENV}-mysql/master_password --with-decryption --query Parameter.Value --output text", returnStdout: true).trim()
                }
                }
            }
        }
        stage('Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan -var-file=terraform.tfvars -out=tfplan'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Publish Plan') {
            steps {
                archiveArtifacts artifacts: "${TF_DIR}/tfplan.txt", fingerprint: true
            }
        }

        stage('Approval') {
            when {
                allOf {
                    expression { params.ACTION == 'apply' }
                    expression { params.ENV == 'prod' }
                }
            }
            steps {
                script {
                    def plan = readFile("${TF_DIR}/tfplan.txt")
                    input message: "Review the plan for PROD. Approve to apply?",
                          ok: "Deploy",
                          parameters: [text(name: 'PlanOutput', defaultValue: plan, description: 'Plan summary')]
                }
            }
        }

        stage('Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }

        stage('Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("${TF_DIR}") {
                    input message: "Confirm DESTROY on ${params.ENV}?", ok: "Destroy"
                    sh 'terraform destroy -var-file=terraform.tfvars -auto-approve'
                }
            }
        }
    }

    post {
        success {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'good',
                message: "✅ Terraform ${params.ACTION} succeeded on *${params.ENV}* — Build #${env.BUILD_NUMBER}"
            )
        }
        failure {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'danger',
                message: "❌ Terraform ${params.ACTION} FAILED on *${params.ENV}* — Build #${env.BUILD_NUMBER}. Check console: ${env.BUILD_URL}"
            )
        }
        aborted {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'warning',
                message: "⚠️ Terraform ${params.ACTION} on *${params.ENV}* was aborted — Build #${env.BUILD_NUMBER}"
            )
        }
    }
}

