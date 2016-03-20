# homework
A ruby hello_app build/deployment configuration exercise.

Uses docker/docker composer directly if you want or vagrant + ubuntu + puppet if you want to keep the changes away from your desktop.

Hello_app is a ruby application deployed to a docker container with phusion passendger, nginx and postgres. During the container startup, the DB is provisioned and the application is downloaded from Git. With this strategy, it is possible to have a fresh version of the application by just starting a new version of the container, which makes the environment ready for development and testing. 

From a security perspective, the puppet scripts are sanitizing the VM in the similar way we would sanitize a production environment, making the development/testing machines closer to a production one. 

Openshift was used for the sake of testing routing and usage outside of a developer's realm.

## Instructions
 - local machine via docker-compose (https://docs.docker.com/compose/install/)
 	- docker-compose up

 - local machine via vagrant (which will run puppet + docker)
 	- vagrant up

 - PaaS deployment using Openshift (You don't need permission to run privileged containers)
 	- oc new-project homework-dev
 	- oc new-app https://github.com/slaterx/homework --name=hello-app --strategy=docker -e TZ=Pacific/Auckland
 	- oc expose service hello-app --hostname=hello-app.example.com

## Improvements
* **DB**: The docker composer is ready to host another container with postgres and bootstrap the DB, but the application is using so far a local one. We need to move the migration step from Dockerfile to the my_init.d, so there will be proper networking in place for the external connection to happen.

* **Load Balancing**: This exercise has no in-house load balancing capability. On one hand, it would be better to have it available for earlier testing, although this would also add more complexity to the overall solution. On the other hand, when getting closer to production, it's very likely the load balancing role would be played by a component outside of this solution, either because it would be in a shared tenancy, or because its management may belong to another department for which we couldn't have control.