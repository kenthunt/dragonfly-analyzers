#!/usr/bin/env bats

function setup() {
    redis-server --daemonize yes --loadmodule /usr/local/lib/redis-ml.so 3>&- &
    redis-cli flushall 3>&- &
    cat /dev/null > /var/log/dragonfly-mle/dragonfly-priority-test.log
    cat /dev/null > /var/log/dragonfly-mle/debug.log
    cat /dev/null > /var/log/dragonfly-mle/dragonfly-mle.log
}

function teardown() {
    redis-cli shutdown
}

@test "Test Alert Triage" {
    # skip "For debug purposes only. Output depends on the analyzers included in the scores."
    # Copy Test Files Into Position
    cp machine-learning/dga-lr-mle.lua /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/ip-blacklist.lua /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/ip-geolocation.lua /usr/local/dragonfly-mle/analyzer/.
    cp anomaly/country-anomaly.lua /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/ip-utils.lua /usr/local/dragonfly-mle/analyzer/.
    cp util/utils.lua /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/internal-ip.lua /usr/local/dragonfly-mle/analyzer/.
    cp event-triage/alert-dns-cache.lua /usr/local/dragonfly-mle/analyzer/.
    cp event-triage/overall-priority.lua /usr/local/dragonfly-mle/analyzer/.
    cp anomaly/time-anomaly.lua /usr/local/dragonfly-mle/analyzer/.
    cp anomaly/signature-anomaly.lua /usr/local/dragonfly-mle/analyzer/.
    cp top-talkers/total-bytes-rank.lua /usr/local/dragonfly-mle/analyzer/.
    cp util/write-to-log.lua /usr/local/dragonfly-mle/analyzer/.
    cp util/router-filter.lua /usr/local/dragonfly-mle/analyzer/.
    cp test/overall-priority/priority-test-config.lua /usr/local/dragonfly-mle/config/config.lua
    cp test/overall-priority/priority-test-filter.lua /usr/local/dragonfly-mle/filter/.
    cp test/overall-priority/priority-test-data.json /usr/local/mle-data/.

    cp ip-util/ipblocklist.txt /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/RW_IPBL.txt /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/zeus_badips.txt /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/IP2LOCATION-LITE-DB1.CSV /usr/local/dragonfly-mle/analyzer/.
    cp ip-util/country-codes.txt /usr/local/dragonfly-mle/analyzer/.

    cd /usr/local/dragonfly-mle/analyzer
    sed -i "s/local subnet_ipv4 =.*/local subnet_ipv4 = '71.219.178.0'/g" internal-ip.lua
    cd $OLDPWD

    # Fire Up Dragonfly
    cd /usr/local/dragonfly-mle
    ./bin/dragonfly-mle 3>&- &
    dragonfly_pid=$!
    echo "# $dragonfly_pid"
    cd $OLDPWD

    timeout=60
    n_lines=12
    log_file="/var/log/dragonfly-mle/dragonfly-priority-test.log"

    # wait until the log file has the expected number of lines
    ./test/wait.sh $log_file $n_lines $timeout 3>&-
    wait_status=$?

    #Shutdown Dragonfly
    run bash -c "pkill -P $dragonfly_pid"
    [ "$status" -eq 0 ]
    run bash -c "kill -9 $dragonfly_pid"
    [ "$status" -eq 0 ]
    [ "$wait_status" -eq 0 ]

    # Validate Output
#   run bash -c "cat /var/log/dragonfly-mle/dragonfly-priority-test.log | grep '\"event_type\":\"alert\"' | tail -n 1 | jq -r 'if .priority.priority then .priority.priority|@text else empty end'"
#   [ "$status" -eq 0 ]
#   [ "$output" = "1.2" ]
#
#   run bash -c "cat /var/log/dragonfly-mle/dragonfly-priority-test.log | grep '\"event_type\":\"alert\"' | tail -n 1 | jq -r 'if .priority.details.dga.domain then .priority.details.dga.domain|@text else empty end'"
#   [ "$status" -eq 0 ]
#   [ "$output" = "client.dropbox-dns.com" ]

#   run bash -c "cat /var/log/dragonfly-mle/dragonfly-priority-test.log | grep '\"event_type\":\"alert\"' | tail -n 1 | jq -r 'if .priority.details.time.score then .priority.details.time.score|@text else empty end'"
#   [ "$status" -eq 0 ]
#   [ "$output" = "1" ]
} 
