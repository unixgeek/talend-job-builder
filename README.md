# Talend Job Builder
Talend Job Builder is a containerized utility (btj.sh) intended to automate the build of Talend jobs from Git. This is
based on the [code-gen](https://github.com/TalendStuff/code-gen/) project.

## Usage
    usage: JOB_NAME [OPTIONAL_PARAMS]
- JOB_NAME: The name of the job in the Talend project to build
- OPTIONAL_PARAMS: Optional extra parameters to pass to Talend or code-gen.

## Example
### Build a job in the current directory.
    docker container run --rm -i -t -u $(id -u):$(id -g) -v $(pwd):/home/talend/source -v$(pwd)/target:/home/talend/target -t talend-job-builder Print_Context

## Notes
* For Talend jobs that require extra jars, like for MariaDB, you will need to create an image off of this one and copy
them to Talend. Looking for better options.

## Credits
- [code-gen](https://github.com/TalendStuff/code-gen/)
- The entrypoint.sh script was based on a script from a Talend expert named Steven.

Two options:
1. Run container as a cmd line compiler. Would be good for building an artifact that can be downloaded and inspected.
2. Build container off the same image (as a builder) and push to registry. Needs a pod definition for k8s.

Open questions:
* What about a monolithic repository?
* How to handle context files. Script to map ENV to .properties.
* What about creating a volume with the context file?

Use sdk man
Use distroless java?

config.ini has some eclipse.p2.* references. maybe use that ?
is it maven 3.5.3?

add exec to entrypoint.

* https://github.com/GoogleContainerTools/distroless/blob/main/java/README.md
* https://github.com/TalendStuff/code-gen/

Why is the builder image 2GB?


* env-to-properties shim
* use a volume that contains the properties file
* use --context_param instead of file


  https://dev.azure.com/stevenmckee/PersonalSpace/_git/tosbd-job-builder?path=/bin