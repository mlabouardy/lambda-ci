def bucket = 'deployment-packages'
def functionName = 'Fibonacci'
def region = 'us-east-1'

node('slaves'){
    stage('Checkout'){
        checkout scm
    }

    stage('Test'){
        sh 'go get -u github.com/golang/lint/golint'
        sh 'go get -t ./...'
        //sh 'golint -set_exit_status'
        sh 'CGO_ENABLED=0 go vet .'
        sh 'go test .'
    }

    stage('Build'){
        sh 'GOOS=linux go build -o main main.go'
        sh "zip ${commitID()}.zip main"
    }

    stage('Push'){
        sh "aws s3 cp ${commitID()}.zip s3://${bucket}"
    }

    stage('Deploy'){
        sh "aws lambda update-function-code --function-name ${functionName} \
                --s3-bucket ${bucket} \
                --s3-key ${commitID()}.zip \
                --region ${region}"
    }

    if (env.BRANCH_NAME == 'master') {
        stage('Publish') {
            sh "aws lambda publish-version --function-name ${functionName} \
                    --region ${region}"
        }
    }
}

def commitID() {
    sh 'git rev-parse HEAD > .git/commitID'
    def commitID = readFile('.git/commitID').trim()
    sh 'rm .git/commitID'
    commitID
}