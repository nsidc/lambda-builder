#!/bin/bash

echo "shellcheck"
find . -type f -name "*.sh" -exec shellcheck {} \;
shellcheck_exit=$?

# exit with failure if any of the above commands failed
exit $((shellcheck_exit))
