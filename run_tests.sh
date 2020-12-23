#!/bin/bash

echo "\nshellcheck"
shellcheck $(find . -type f -name "*.sh")
shellcheck_exit=$?

# exit with failure if any of the above commands failed
exit $((shellcheck_exit))
