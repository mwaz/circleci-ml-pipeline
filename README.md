# Automating ML Workflows with CircleCI CI/CD Tools for MLOps

This repository provides an example of how a machine learning (ML) workflow can be split into stages and processed using CircleCI's CI/CD platform for MLOps. This allows for the full automation and monitoring of ML workflows, while adding additional capabilities like alerts, and deploying to auto-scaling cloud environments for heavy workloads.

Given the complexity and bespoke nature of ML models and workflows, this example repository is demonstrative - it shows you how the ML process can be broken down into separate stages, and then integrated into a CI/CD pipeline for granular reporting and management based on triggers such as schedules, data updates, or model updates.

Thus, this example uses a very simple TensorFlow/Keras based ML workflow, as the focus is on the CI/CD automation pipeline. Your workflows' stages and methodology will most likely differ, but the principles will be the same - break down your ML process, automate the training and retraining of data, and let your CI/CD platform handle any failures and notify the responsible parties as part of MLOps best-practices.

## Credits

The code in this repository is adapted from the following TensorFlow tutorial:

https://github.com/tensorflow/tfx/blob/master/docs/tutorials/serving/rest_simple.ipynb 

## Definitions

If you're unfamiliar, here's a quick run-down of the ML tools used in this repo:

- TensorFlow: An open source machine learning (ML) platform that runs on Python.
- Keras: A deep-learning neural network that provides pre-built ML models that runs on top of TensorFlow.
- MNIST: The Modified National Institute of Standards and Technology database contains datasets containing images and glyphs for testing image processing systems - This example uses data from it as a test dataset for training the ML model.

## Usage notes

All commands in this repository should be invoked from the root directory, for example:

    sh ./tools/install.sh
    python3 ./ml/1_build.py

There are a lot of comments in the files in the Python and Bash scripts that explain what's going on, be sure to read them if you run into trouble!

## Repo contents

This repository contains the following directories:
- `ml` with an example ML workflow split across several Python scripts.
- `tools` contains Bash scripts for setting up the environment to run the `ml` workflow, testing the workflows locally, and configuring a TensorFlow Serving server.
- `.circleci` contains the CircleCI `config.yml` that defines the CircleCI pipelines that will call the `ml` scripts.
  - Two workflows are included, one to build, and one to rebuild. Each workflow demonstrates different CircleCI features.

#### Quick start

Rather than having a really long README file, each script in this repository is commented. Start in the `tools` directory to see how to install your ML environment, server, and then move onto reading through the `ml` Python scripts to see what they do.

### ML Python scripts

The scripts in the `ml` directory provide the core functionality. Each script contains a stage in a simple ML workflow:

#### Build

- Building a machine learning model is a multi-step process that involves collecting, validating, and understanding your data, and building a program that can analyze and create insights from that data.
- In our example, the build phase simply imports and prepares some demo data, ready to train an existing [Keras sequential model](https://keras.io/guides/sequential_model/) in the next step. In a real-world scenario, you'd supply your own data.

#### Train

- In this step, carefully prepared, highly accurate data with known outcomes is fed to the model so that it can start learning.
- This uses the training data from the build phase. 

#### Test

- As the training data has ben pre-analyzed and is well understood, we can tell if the trained model is accurate by comparing its output with the already known outcomes.
- In our scripts, we do this by comparing the testing data collected in the build phase.

#### Package

- This prepares the trained model for use in a separate environment - saving it in a standard format and making it portable so that it can be deployed for use elsewhere.
- It also uploads it to a package store/staging area. You could use the [S3 Orb](https://circleci.com/developer/orbs/orb/circleci/aws-s3) for this purpose to upload your ML artifacts and training data instead of SSH as used in this tutorial.

#### Deploy

- This stage involves deploying your trained and packaged model to your production ML environment.
- In this example, the packaged model is uploaded to a directory which [TensorFlow Serving](https://www.tensorflow.org/tfx/guide/serving) loads its models from.

#### Retrain

- Deploying a model doesn't mean it's finished - new data will be arriving which can be used to retrain it to improve its accuracy.
- In this example, a retraining step can replace the train step in this workflow to retrain an existing model rather than creating a new one.

#### Test deployed model

- Ensuring a successful deployment is important, so this example makes a quick REST call to TensorFlow Serving to ensure that it receives a response.

## Prerequisites

- A CircleCI self-hosted runner.
  - This can be a local machine or set up as part of an [auto-scaling deployment](https://circleci.com/blog/autoscale-self-hosted-runners-aws/) for larger workloads.
  - See **Python** below for installing additional requirements for the runner.
- Or, you can run this pipeline from CircleCI managed compute cloud resources.
  - To keep this example simple, it's assumed that it's running on a self-hosted runner with access to the required network assets (model storage location, Tensorflow Serving server).
  - However, it may be preferable to run this on CircleCI's infrastructure to take advantage of the available pre-built images and machine classes (see the **GPU** section below), or simply to reduce the amount of infrastructure you have to maintain by using CircleCI's managed cloud resources
    - If you are doing this, you will need to make sure CircleCI can access the required network resources by securely exposing them, or adding SSH tunnels or [VPN configuration](https://support.circleci.com/hc/en-us/articles/360049397051-How-To-Set-Up-a-VPN-Connection-During-Builds) to your CircleCI pipeline steps or scripts.
    - If you want to quickly test this repository on CircleCI's managed compute without connecting it to your network resources, comment out the *package*, *deploy*, *retrain* and *test_deployed_model* steps in the pipeline.
- A CircleCI account and a GitHub account.   
  - [CircleCI quickstart guide](https://circleci.com/docs/getting-started/).
- A server with SSH access and Docker installed. 
  - See **TensorFlow Serving** below for a script for setting this up.
  - Your runner should be able to reach this machine on the network.

### Python

The machine that will run these tasks (either as a CircleCI self-hosted runner or if running the scripts locally) will require Python 3 be installed. On Ubuntu, run:

    sudo apt install python3 pip3

You can install a virtual environment and the required Python packages by running the install script:

    sh ./tools/install.sh

If you want to install the packages yourself, run:

    pip install tensorflow numpy matplotlib pysftp python-dotenv paramiko requests

### TensorFlow Serving

An additional script is supplied for spinning up a Docker container running TensorFlow Serving for testing:

    sh ./tools/install_server.sh

You will need to supply the details of the machine this server is running on in your `.env` file.

### Test this Project Locally

To test this project without importing it into CircleCI, you can run `test_build.sh` and `test train.sh` after creating a `.env` file with the necessary configuration as shown in `.env.example`.

## Setting up the project in CircleCI

You will need to fork this repository and [import it into CircleCi](https://circleci.com/docs/create-project/). 

### Setting environment variables

You will need to set the following [environment variables](https://circleci.com/docs/env-vars/) in CircleCi which will be used to generate the `.env` file containing your secrets on the runner when the pipeline is executed:

- DEPLOY_SERVER_HOSTNAME
- DEPLOY_SERVER_USERNAME
- DEPLOY_SERVER_PASSWORD
- DEPLOY_SERVER_PATH

### Using CircleCI

The included CircleCI configuration in `.circleci/config.yml` will run the included scripts as a CI/CD pipeline. You can build on this example to experiment with different [CircleCI features](https://circleci.com/docs/).

If a job fails, you can rapidly respond and confirm the issue in the cci UI by re-running only the failed parts of your workflow https://circleci.com/docs/workflows/#rerunning-a-workflows-failed-jobs.

CircleCI requires a valid configuration to run. You can use the CircleCI web interface to edit your `.circleci/config.yml` file, which will include linting and show you any schema problems, or use the [CircleCI command line tools](https://circleci.com/docs/local-cli/) to [validate your configuration](https://circleci.com/docs/how-to-use-the-circleci-local-cli/#validate-a-circleci-config) locally.

### Using GPU for ML tasks in the cloud and locally

GPU resources can make fast work of ML tasks. 

CircleCI provides [GPU execution environments](https://circleci.com/execution-environments/gpu/) for compute-intensive applications that are well suited for ML.

You can also use self hosted runners to use your own GPU resources.

Once you have an environment with GPU resources available, you can configure your ML package to utilize them (if the ML platform supports it). You can see how to do this with TensorFlow [here](https://www.tensorflow.org/install/gpu_plugins).

### Notifications

By default you will receive notifications on job failures and required approvals to your default CircleCi email address. You can configure other team members to receive notifications, set up web notifications, or connect your CircleCI pipeline to Slack or IRC - see the documentation for this [here](https://circleci.com/docs/notifications/).

By customizing your notifications, you can make sure the right person is notified to fix a failed job and ensure your ML system stays accurate and available.

### Onwards!

This example gives an overview of the CircleCI CI/CD functionality that is beneficial to MLOps and automating ML workflows. Once you have experimented with what CircleCI can do with this example, you can start breaking down and automating your own ML workflows, and build CircleCI configurations for them that implement the functionality displayed here such as [scheduling runs](https://circleci.com/docs/scheduled-pipelines/), [conditional logic](https://support.circleci.com/hc/en-us/articles/360043638052-Conditional-steps-in-jobs-and-conditional-workflows), [deloying after approval](https://circleci.com/blog/deploying-with-approvals/), and [triggering notifications](https://circleci.com/docs/notifications/) based on the results of your pipelines.
