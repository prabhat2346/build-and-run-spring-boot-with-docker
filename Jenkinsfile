node('master'){
             def environment=ENVIRONMENT_VAR
             def serviceName="build-and-run-spring-boot-with-docker"
             echo "${serviceName}"


             //UAT Regisrty Details.
             
             def imageName = "docker-boot-intro"
             env.UAT_IMAGE_TAG = "${env.uatDockerRegistry}/${imageName}"
	         env.STG_IMAGE_TAG = "${env.stgDockerRegistry}/${imageName}"
	         env.PRD_IMAGE_TAG = "${env.prdDockerRegistry}/${imageName}"
   
             
             def imageTag=""
             def dockerRegistry=""
             def dockerCredential=""
             def servicePrincipal=""

             def active_profile="${environment}"
                                   

             //Env spesfication
               switch(ENVIRONMENT_VAR) {
               case "uat":
		    imageTag=env.UAT_IMAGE_TAG 
		    dockerRegistry=env.uatDockerRegistry
		    dockerCredential="docker-uat"
		    servicePrincipal="sp-uat"
		    break
		  case "stg":
		    imageTag=env.STG_IMAGE_TAG
		    dockerRegistry=env.stgDockerRegistry
		    dockerCredential="docker-stg"
		    servicePrincipal="sp-stg"
		    break
		  case "prd":
		    imageTag=env.PRD_IMAGE_TAG
		    dockerRegistry=env.prdDockerRegistry
		    dockerCredential="docker-prd"
		    servicePrincipal="sp-prd"
		    break
		  default:
		    error("Please provide a currect environment")
		    break

    }

    stage("SCM"){
      git credentialsId: 'GIT_CREDENTIALS', url: 'https://github.com/prabhat2346/build-and-run-spring-boot-with-docker.git'
    }

//Build & Push process for UAT Environment.
    stage('Build & Push on ${environment}') {

  sh"""
	mvn clean install -DskipTests  "-Dimage.active.profile=${active_profile}" "-Ddocker.image.prefix=${dockerRegistry}"  dockerfile:build 
	"""
	//defining IMAGE name for UAT Environment & pushing the Image.
	def image = imageTag
    echo "${image}"
     withCredentials([usernamePassword(credentialsId: dockerCredential, passwordVariable: 'pass', usernameVariable: 'user')]) {
     sh"""
	 docker login ${user}.azurecr.io -u ${user} -p ${pass}
	 echo ${image}
	 docker push "${image}"
	"""
     }
    }
    stage("AKS Login & Deploy"){
         switch(ENVIRONMENT_VAR) {
         case "uat":    
         withCredentials([kubeconfigFile(credentialsId: 'KUBERNETES_CLUSTER_CONFIG', variable: 'KUBECONFIG')]) {
            sh 'az aks get-credentials -g myResourceGroup -n myAkscluster'
            //Capturing the current running Image.
					script{
						oldRevision = sh(returnStdout:true, script:"""
							kubectl get statefulset ${serviceName} -o=jsonpath='{.spec.template.spec.containers[0].image}'
						""")
					}
           //defining image name for UAT Environment
           def image = imageTag
           sh """
              kubectl set image statefulset/"${serviceName}" "${serviceName}"="${image}" -o json
              """
           }
        }
    }
  }
