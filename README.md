# Talend Job Builder
Talend Job Builder is a containerized utility (btj.sh) intended to automate the build of Talend jobs from Git. This is
based on the [code-gen](https://github.com/TalendStuff/code-gen/) project.

## Usage
    usage: btj.sh JOB_NAME PROJECT_DIR TARGET_DIR [OPTIONAL_PARAMS]
- JOB_NAME: The name of the job in the Talend project to build
- PROJECT_DIR: The top level location of the Talend project
- TARGET_DIR: The location to place the built job (optional, defaults to /builder/target)
- OPTIONAL_PARAMS: Optional extra parameters to pass to Talend or code-gen.

## Example
1. Create a container with a volume to access the build after the container is destroyed.

       docker container run --rm -i -v talend:/builder/target -t unixgeek2/talend-job-builder /bin/bash
2. Clone a project.

       git clone https://github.com/unixgeek/TEST.git
3. Build the PrintSomething job and include the shell script launcher.

       /builder/btj.sh PrintSomething /workspace/TEST /builder/target -needJobScript Unix

## Credits
- [code-gen](https://github.com/TalendStuff/code-gen/)
- The btj.sh script was based on a script from a Talend expert named Steven.
