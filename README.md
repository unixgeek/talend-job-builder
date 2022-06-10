# Talend Job Builder
Talend Job Builder is a containerized utility (btj.sh) intended to automate the build of Talend jobs from Git. This is
based on the [code-gen](https://github.com/TalendStuff/code-gen/) project.

## Usage
    usage: btj.sh JOB_NAME GIT_URL GIT_BRANCH [OPTIONAL_PARAMS]
- JOB_NAME: The name of the job in the Talend project to build
- GIT_URL: The URL of the git repository to clone.
- GIT_BRANCH: The branch of the git repository to clone.
- OPTIONAL_PARAMS: Optional extra parameters to pass to Talend or code-gen.

## Example
### Build a job in the current directory.
    docker container run --rm -i -v "$(pwd)":/home/talend/target -t talend-job-builder PrintSomething https://github.com/unixgeek/TEST master -needJobScript Unix

## Notes
* The entry point of the container is the btj.sh script, but it will also allow running any arbitrary command. This is
useful for other setups, like Jenkins.
* For Talend jobs that require extra jars, like for MariaDB, you will need to create an image off of this one and copy
them to Talend. Looking for better options.

## Credits
- [code-gen](https://github.com/TalendStuff/code-gen/)
- The btj.sh script was based on a script from a Talend expert named Steven.
