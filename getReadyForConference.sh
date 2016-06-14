#!/usr/bin/env bash

set -e

WAIT_TIME="${WAIT_TIME:-5}"
RETRIES="${RETRIES:-70}"
SERVICE1_PORT="${SERVICE1_PORT:-8081}"
SERVICE2_PORT="${SERVICE2_PORT:-8082}"
SERVICE3_PORT="${SERVICE3_PORT:-8083}"
SERVICE4_PORT="${SERVICE4_PORT:-8084}"
ZIPKIN_PORT="${ZIPKIN_PORT:-9411}"
RUN_VAGRANT="${RUN_VAGRANT:-yes}"

# ${RETRIES} number of times will try to curl to /health endpoint to passed port $1 and localhost
function curl_local_health_endpoint() {
    curl_health_endpoint $1 "127.0.0.1"
}

# ${RETRIES} number of times will try to curl to /health endpoint to passed port $1 and host $2
function curl_health_endpoint() {
    local PASSED_HOST="${2:-$HEALTH_HOST}"
    local READY_FOR_TESTS=1
    for i in $( seq 1 "${RETRIES}" ); do
        sleep "${WAIT_TIME}"
        curl -m 5 "${PASSED_HOST}:$1/health" && READY_FOR_TESTS=0 && break
        echo "Fail #$i/${RETRIES}... will try again in [${WAIT_TIME}] seconds"
    done
    return $READY_FOR_TESTS
}

function check_app() {
    READY_FOR_TESTS="no"
    curl_local_health_endpoint $1 && READY_FOR_TESTS="yes"
    if [[ "${READY_FOR_TESTS}" == "no" ]] ; then
        echo "Failed to start service running at port $1"
        exit 1
    fi
}

# First run the `./setupPresentationRepo.sh` to initialize the GIT submodule.
./setupPresentationRepo.sh

# Next start the ELK vagrant box with `vagrant up`
if [[ "${RUN_VAGRANT}" == "yes" ]] ; then
    vagrant up
else
    echo -e "\n\nSkipping vagrant setup"
fi

# Next run the `./runApps.sh` script to initialize Zipkin and the apps (check the `README` of `sleuth-documentation-apps` for Docker setup info)
./runApps.sh

echo -e "\n\nChecking if Zipkin is alive"
check_app $ZIPKIN_PORT
echo -e "\n\nChecking if Service1 is alive"
check_app $SERVICE1_PORT
echo -e "\n\nChecking if Service2 is alive"
check_app $SERVICE2_PORT
echo -e "\n\nChecking if Service3 is alive"
check_app $SERVICE3_PORT
echo -e "\n\nChecking if Service4 is alive"
check_app $SERVICE4_PORT

echo -e "\n\nReady to curl first request"

./sleuth-documentation-apps/scripts/curl_start.sh

echo -e "\n\nReady to curl a request that will cause an exception"

./sleuth-documentation-apps/scripts/curl_exception.sh && echo -e "\n\nShould have failed the request but didn't :/" && exit 1 || echo -e "\n\nSent a request and got an exception!"
