# Talend Job Builder

This Docker image is based on [code-gen](https://github.com/TalendStuff/code-gen/) and is for compiling 
Talend Open Studio jobs, primarily in CI/CD.

## Usage

    usage: JOB_NAME [OPTIONAL_PARAMS]
- JOB_NAME: The name of the job in the Talend project to build
- OPTIONAL_PARAMS: Optional extra parameters to pass to Talend or code-gen.
  
*TODO: Document Talend and code-gen parameters.*

## Example

### Compile Standalone

    mkdir target
    docker container run --rm --user $(id -u):$(id -g) \
        --volume $(pwd):/home/talend/source \
        --volume $(pwd)/target:/home/talend/target \
        talend-job-builder Print_Context

### Compile and Create Runnable Image

There is an example Talend project in `example/EXAMPLE` that contains two jobs: Print_Context and Generate_Data. The
`Dockerfile` in `example/EXAMPLE/talend-job-builder` is parameterized to build both jobs.

#### Print_Context

Build:

    cd examples/talend/EXAMPLE
    docker image build --build-arg JOB_NAME=Print_Context \
        --build-arg CONTEXT_NAME=NonProd \
        --file talend-job-builder/Dockerfile \
        --tag print-context .

Run using values provided in the job's context file:

    docker container run --rm print-context

A shell script is provided that reads environment variables and passes them to the job using Talend's `--context_param` 
parameter. The key should be prefixed with `CONTEXT_`. The prefix will be stripped. This does have caveats related to 
characters used in the value and the maximum argument length in the shell.

    docker container run --rm \
        --env CONTEXT_host=nonprod2.example.com \
        print-context

A small utility is provided that reads environment variables and updates the job's context with the values. The key 
should be prefixed with `CONTEXT_`. The prefix will be stripped. This is a safer approach to the shell script mentioned 
above. It does require specifying the location of the context file.

    docker container run --rm \
        --env CONTEXT="Print_Context/example/print_context_0_1/contexts/NonProd.properties" \
        --env CONTEXT_host=nonprod2.example.com \
        print-context

#### Generate_Data

This job requires an external jar to be installed. See `examples/talend/Example/talend-job-builder/prebuild-setup.sh` 
and `builder/build-talend-job.sh` for how this works.

Build:

    cd examples/talend/EXAMPLE 
    docker image build --build-arg JOB_NAME=Generate_Data \
        --build-arg CONTEXT_NAME=Default \
        --file talend-job-builder/Dockerfile \
        --tag generate-data .

Run:

    docker container run --rm generate-data

## Talend Scripts
The scripts in the `talend` directory can be used outside of this Docker process.

## Credits

- [code-gen](https://github.com/TalendStuff/code-gen/)
- The entrypoint.sh script was based on a script from a Talend expert named Steven.

## Todo
* check license
* can distroless still be used somehow?