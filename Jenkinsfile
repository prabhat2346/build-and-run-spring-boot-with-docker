node{

    stage("maven Clean Build"){
      def mavenHome = tool name: "Maven-3.6.1", type: "maven"
      def mavenCMD = "${mavenHome}/bin/mvn"
     sh "${mavenCMD} clean package"
    }

    stage("Build Docker Image"){
        sh "docker build -t uatacr.azurecr.io/boot ."
        sh "docker image ls"
    }

    stage("Docker Push"){
       withCredentials([usernamePassword(credentialsId: 'docker-uat', passwordVariable: 'pass', usernameVariable: 'user')]) {
        sh "docker login ${user}.azurecr.io -u ${user} -p ${pass}"
        sh "docker push uatacr.azurecr.io/boot"
       }
    }
    stage("AKS Login"){
        withCredentials([kubeconfigFile(credentialsId: 'KUBERNETES_CLUSTER_CONFIG', variable: 'KUBECONFIG')]) {
            sh 'kubectl get pods -o wide'
            sh 'az aks get-credentials -g myResourceGroup -n myAkscluster'
        }
    }
}


~                                                                                                                                                                        
~                        
