# homework
A ruby hello_app build/deployment configuration exercise.

Uses docker/docker composer directly if you want or vagrant + ubuntu + puppet if you want to keep the changes away from your desktop. Just clone this repository to your computer and select one of the deployment options.

Hello_app is a ruby application deployed to a docker container with phusion passendger, nginx and postgres. During the container startup, the DB is provisioned and the application is downloaded from Git. With this strategy, it is possible to have a fresh version of the application by just starting a new version of the container, which makes the environment ready for development and testing. 

From a security perspective, the puppet scripts are sanitizing the VM in the similar way we would sanitize a production environment, making the development/testing machines closer to a production one. 

From a testing perspective, TravisCI runs periodically a test on each commit.

Openshift was used for the sake of testing routing and usage outside of a developer's realm.

## Instructions
 - Local machine via docker-compose (Linux) (https://docs.docker.com/compose/install/)
 	```
 	docker-compose up
 	```

 - Local machine via vagrant (OSX, Windows) (which will run puppet + docker)
 	```
 	vagrant up
 	```

 - PaaS deployment of a dual node using Openshift (You don't need permission to run privileged containers)
 	```
 	oc new-project homework-staging
 	oc new-app https://github.com/slaterx/homework --name=hello-app --strategy=docker -e TZ=Pacific/Auckland
 	oc expose service hello-app --hostname=hello-app-stag.example.com
 	oc scale dc hello-app --replicas=2 #If you want high availability on the app
 	```

 - PaaS deployment of a dual node using AWS Elastic Beanstalk
 	```
 	eb init hello-app
 	eb create hello-app-staging
 	eb deploy
 	eb scale 2 #If you want high availability on the app
 	```

## Problems found (and how they were mitigated)
 - **Lack of flexibility on the database configuration**: The application uses hardcoded database names. The easiest way to overcome this was to open config/databases.rb to get the DB names and add them inside the deployment strategy. The best way to address this would be to change the source to accept variables and pass then as part of our deployment, in the same way we are passing the username and password.

 - **Security controls**: The application and database are pretty standard, yet on a production environment it is important to have bits and pieces in place to avoid vulnerabilities or to meet a specific security control. The easiest way to overcome this was to use puppet as a configuration managament tool to declare how do we want the environment to look like. The best way to address this would be to have puppet rules applied both at the container level and at the application/database level.

 - **Testing**: There was a need for continuous testing. The easiest way to overcome this was to setup TravisCI on this git repository to run on each commit. The best way to address this would be to have TravisCI testing each commit from each environment, from development to production.

 - **Developer workflow**: A good scenario for a deployment workflow is when both the developer and the sysadmin need to do minimal intervention on the deployment process. This means that the environment is source-controlled (just like the application source code) and the strategy is repeatable on several different platforms. The easiest way to overcome this was to have both a vagrant and a docker-compose deployment strategy (which allowed different ways to develop the environment with the same result) and to deploy into both openshift (Opensource PaaS) and AWS (Enterprise PaaS) to test production-like environments. A better way would be to do the same as before but having different branches for each environment, from development to production.

## Improvements
* **DB**: The docker composer is ready to host another container with postgres and bootstrap the DB, but the application is using so far a local one. We need to move the migration step from Dockerfile to the my_init.d, so there will be proper networking in place for the external connection to happen.

* **Load Balancing**: This exercise has no in-house load balancing capability. On one hand, it would be better to have it available for earlier testing, although this would also add more complexity to the overall solution. On the other hand, when getting closer to production, it's very likely the load balancing role would be played by a component outside of this solution, either because it would be in a shared tenancy, or because its management may belong to another department for which we couldn't have control.