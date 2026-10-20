pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        IMAGE = 'localhost:5000/vue-cicd-test/app'
    }

    stages {
        stage('1 拉代码') {
            steps {
                checkout scm
                script {
                    env.TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                }
                echo "本次版本号：${env.TAG}"
            }
        }

        stage('2 装依赖') {
            steps { sh 'pnpm install --frozen-lockfile' }
        }

        stage('3 代码规范') {
            steps { sh 'pnpm run lint' }
        }

        stage('4 单元测试') {
            steps { sh 'pnpm run test:unit' }
        }

        stage('5 打包') {
            steps {
                sh 'pnpm run build'
                sh 'pnpm run size'
            }
        }

        stage('6 构建镜像') {
            steps {
                sh "docker build -t ${IMAGE}:${env.TAG} ."
            }
        }

        stage('7 推送镜像') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'harbor-credentials',
                    usernameVariable: 'H_USER',
                    passwordVariable: 'H_PASS'
                )]) {
                    sh 'echo "$H_PASS" | docker login localhost:5000 -u "$H_USER" --password-stdin'
                    sh "docker push ${IMAGE}:${env.TAG}"
                }
            }
        }

        stage('8 部署') {
            steps {
                sh "sh deploy.sh ${env.TAG}"
            }
        }
    }

    post {
        success { echo '✅ 全部通过，版本已上线' }
        failure { echo '❌ 上面第一个变红的阶段就是问题所在' }
    }
}