#!/bin/bash

echo "shellcheck"
find . -type f -name "*.sh" -print0 | xargs -0 shellcheck
shellcheck_exit=$?

# exit with failure if any of the above commands failed
exit $((shellcheck_exit))
