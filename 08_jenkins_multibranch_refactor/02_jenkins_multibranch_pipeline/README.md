# 02 Jenkins multibranch pipeline

In this example we are going to change our current Jenkins project to be a multi branch pipeline in order to do different actions based on the pushed branch.

We will start from `01-jenkins-pipeline`.

## Prerequisites

You will need the same requirements from `01-jenkins-pipeline`.

## Steps to build it

We'll start by destroying our current Jenkins project by clicking the `Delete project` button.

![Delete project](../readme-resources/02-jenkins-delete-project.png)

We'll create a  new project by clicking on`New Item` 

![New item](../readme-resources/02-jenkins-new-item.png)



This time we'll select `Multibranch pipeline`.

![Multi branch pipeline](../readme-resources/02-multibranch-project.png)



Add a new branch source and choose GitHub.

![Branch source](../readme-resources/02-branch-source.png)

We'll add the same repository and chose the discovery type `All branches` 

![Branch source settings](../readme-resources/02-github-branch-source.png)



Well see the Scan Repository running and our `master` branch being build.

![Scan Repository Log](../readme-resources/02-branch-discovery.png)

Now each branch will have its own folder inside the Jenkins project.

![Multibranch status](../readme-resources/02-jenkins-multibranch-status.png)

# About Basefactor + Lemoncode

We are an innovating team of Javascript experts, passionate about turning your ideas into robust products.

[Basefactor, consultancy by Lemoncode](http://www.basefactor.com) provides consultancy and coaching services.

[Lemoncode](http://lemoncode.net/services/en/#en-home) provides training services.

For the LATAM/Spanish audience we are running an Online Front End Master degree, more info: http://lemoncode.net/master-frontend
