# Talend Job Builder

This Docker image is based on [code-gen](https://github.com/TalendStuff/code-gen/) and is for building 
Talend Open Studio jobs, primarily in CI/CD.

## Setup
If a job has dependencies or needs custom preparation you can use a shell script hook. When talend-job-builder runs, 
it looks for `talend-job-builder/prebuild-setup.sh` in the Talend project root and executes it before building the job.

For dependencies, there are scripts in `talend` that can be useful. Each script is self-documented and some can be used
with talend-job-builder or standalone. 

## Usage
You will need to map the `/home/talend/source` and `/home/talend/target` directories. `source` should be the root of 
the Talend project. `target` should be where the built job will be located.

    usage: talend-job-builder JOB_NAME [OPTIONAL_PARAMS]
- JOB_NAME: The name of the job in the Talend project to build
- OPTIONAL_PARAMS: Optional extra parameters to pass to Talend or code-gen.
  
*TODO: Document Talend and code-gen parameters.*

## Examples
There is a Talend project named EXAMPLE in `examples/talend` that contains two jobs: Print_Context and Generate_Data.
Print_Context has no dependencies and simply prints out the context. Generate_Data has a dependency and prints out
random data.

### Print_Context
Here we are specifying NonProd as the context to be set in the run script. Without specifying, it seems that Talend 
sets the context to Default, even if that context does not exist.
```shell
docker container run --rm --user $(id -u):$(id -g) \
    --volume $(pwd)/examples/talend/EXAMPLE:/home/talend/source \
    --volume /tmp:/home/talend/target \
    talend-job-builder Print_Context -contextName NonProd
```

### Generate_Data
This job requires an external jar to be installed into the Talend workspace. This usually gets installed from the 
Talend UI, but that is not feasible here. See `examples/talend/Example/talend-job-builder/prebuild-setup.sh` 
and `builder/build-talend-job.sh` for how this works.
```shell
docker container run --rm --user $(id -u):$(id -g) \
    --volume $(pwd)/examples/talend/EXAMPLE:/home/talend/source \
    --volume /tmp:/home/talend/target \
    talend-job-builder Generate_Data
```

## Building as a Docker Image
talend-job-builder can also be used as a stage in your Docker build. It isn't strictly required, but the shell script
Talend generates when building a job should use exec in order for the job to be PID 1. You can do your own thing or 
use `talend/job_run_template.sh`.

### Examples
The `Dockerfile` in `example/EXAMPLE/talend-job-builder` is parameterized to build any job and might be a good starting
point. If you have a lot of jobs and dependencies it might be better to have a base Dockerfile built off of 
talend-job-builder with the dependencies already installed and use that as the build stage.

#### Print_Context
Build:
```shell
docker buildx build --build-arg JOB_NAME=Print_Context \
    --build-arg CONTEXT_NAME=NonProd \
    --file examples/talend/EXAMPLE/talend-job-builder/Dockerfile \
    --tag print-context examples/talend/EXAMPLE
```
Run using values provided in the job's context file:
```shell
docker container run --rm print-context
````
A shell script is provided that reads environment variables and passes them to the job using Talend's `--context_param` 
parameter. The key should be prefixed with `CONTEXT_`. The prefix will be stripped. This does have caveats related to 
characters used in the value and the maximum argument length in the shell.
```shell
docker container run --rm --env CONTEXT_host=nonprod2.example.com print-context
```
A small utility is provided that reads environment variables and updates the job's context with the values. The key 
should be prefixed with `CONTEXT_`. The prefix will be stripped. This is a safer approach to the shell script mentioned 
above. It does require specifying the location of the context file.
```shell
docker container run --rm \
    --env CONTEXT="Print_Context/example/print_context_0_1/contexts/NonProd.properties" \
    --env CONTEXT_host=nonprod2.example.com \
    print-context
```

#### Generate_Data
Build:
```shell
docker buildx build --build-arg JOB_NAME=Generate_Data \
    --build-arg CONTEXT_NAME=Default \
    --file examples/talend/EXAMPLE/talend-job-builder/Dockerfile \
    --tag generate-data examples/talend/EXAMPLE
```
Run:
```shell
docker container run --rm generate-data
```

## Credits
- [code-gen](https://github.com/TalendStuff/code-gen/)
- The entrypoint.sh script was based on a script from a Talend expert named Steven.
