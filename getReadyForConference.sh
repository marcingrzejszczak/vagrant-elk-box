#!/usr/bin/env bash

WAIT_TIME="${WAIT_TIME:-5}"
RETRIES="${RETRIES:-70}"
SERVICE1_PORT="${SERVICE1_PORT:-8081}"
ZIPKIN_PORT="${ZIPKIN_PORT:-9411}"

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


# First run the `./setupPresentationRepo.sh` to initialize the GIT submodule.
./setupPresentationRepo.sh

# Next start the ELK vagrant box with `vagrant up`
vagrant up

# Next run the `./runApps.sh` script to initialize Zipkin and the apps (check the `README` of `sleuth-documentation-apps` for Docker setup info)
./runApps.sh

READY_FOR_TESTS="no"
curl_local_health_endpoint $ZIPKIN_PORT && READY_FOR_TESTS="yes"

if [[ "${READY_FOR_TESTS}" == "no" ]] ; then
    echo "Failed to start Zipkin service"
    exit 1
fi

READY_FOR_TESTS="no"
curl_local_health_endpoint $SERVICE1_PORT && READY_FOR_TESTS="yes"

if [[ "${READY_FOR_TESTS}" == "no" ]] ; then
    echo "Failed to start service 1"
    exit 1
fi

./sleuth-documentation-apps/scripts/curl_start.sh
