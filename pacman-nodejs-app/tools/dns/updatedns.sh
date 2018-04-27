#!/usr/bin/env bash
#
# kmt.sh - Kubernetes Migration Tool
#
#
#
set -e

function usage {
    echo "$0: [OPTIONS] [-t|--to-context CONTEXT [CONTEXT]...] [-n|--namespace NAMESPACE] [-z|--zone ZONE_NAME] [-d|--dns DNS_NAME]"
    echo "  Optional Arguments:"
    echo "    -h, --help             Display this usage"
    echo "    -v, --verbose          Increase verbosity for debugging"
    echo "  Required arguments:"
    echo "    -t, --to-context       destination CONTEXTs to migrate application"
    echo "    -n, --namespace        namespace containing Kubernetes resources to migrate"
    echo "    -z, --zone             name of zone for your Google Cloud DNS e.g. zonename"
    echo "    -d, --dns              domain name used for your Google Cloud DNS zone e.g. 'example.com.'"
}

function parse_args {
    req_arg_count=0

    if [[ ${1} == '-h' || ${1} == '--help' ]]; then
        usage
        exit 1
    fi

    while [[ $# -gt 1 ]]; do
        case "${1}" in
            -t|--to-context)
                DST_CONTEXTS+=" ${2}"
                (( req_arg_count += 1 ))
                shift
                ;;
            -n|--namespace)
                NAMESPACE="${2}"
                (( req_arg_count += 1 ))
                shift
                ;;
            -z|--zone)
                ZONE_NAME="${2}"
                (( req_arg_count += 1 ))
                shift
                ;;
            -d|--dns)
                DNS_NAME="${2}"
                (( req_arg_count += 1 ))
                shift
                ;;
            -v|--verbose)
                set -x
                ;;
            -h|--help)
                usage
                exit 1
                ;;
            *)
                echo "Error: invalid argument '${arg}'"
                usage
                exit 1
                ;;
        esac
        shift
    done

    if [[ ${req_arg_count} -ne 4 ]]; then
        echo "Error: missing required arguments"
        usage
        exit 1
    fi

}

function validate_contexts {
    if ! $(kubectl config get-contexts -o name | grep ${SRC_CONTEXT} &> /dev/null); then
        echo "Error: source context '${SRC_CONTEXT}' is not valid. Please check the context name and try again."
        usage
        exit 1
    fi

    if ! $(kubectl config get-contexts -o name | grep ${DST_CONTEXT} &> /dev/null); then
        echo "Error: destination context '${DST_CONTEXT}' is not valid. Please check the context name and try again."
        usage
        exit 1
    fi

}

function validate_namespace {
    kubectl config use-context ${SRC_CONTEXT}

    if ! $(kubectl get namespace ${NAMESPACE} &> /dev/null); then
        echo "Error: invalid namespace '${NAMESPACE}'"
        usage
        exit 1
    fi
}

function validate_zone_name {
    zname=$(gcloud dns managed-zones list --filter="name = ${ZONE_NAME}" --format json | jq -r '.[0].name')

    if [[ ${zname} != ${ZONE_NAME} ]]; then
        echo "Error: invalid zone name '${ZONE_NAME}'"
        usage
        exit 1
    fi
}

function validate_dns_name {
    dname=$(gcloud dns managed-zones list --filter="name = ${ZONE_NAME}" --format json | jq -r '.[0].dnsName')

    if [[ ${dname} != ${DNS_NAME} ]]; then
        echo "Error: invalid DNS name '${DNS_NAME}'"
        usage
        exit 1
    fi
}

function validate_args {
    validate_contexts
    validate_namespace
    validate_zone_name
    validate_dns_name
}

function verify_dns_update_propagated {
    verify_services_ready
    verify_deployments_ready
}

function start_dns_transaction {
}

function remove_old_dns_entry {
}

function add_new_dns_entry {
}

function execute_dns_transactin {
}

function run_dns_transaction {
    start_dns_transaction
    remove_old_dns_entry
    add_new_dns_entry
    execute_dns_transaction
}

function perform_dns_updates {
    echo "Updating ${NAMESPACE} DNS to cluster(s) ${DST_CONTEXT}..."
    run_dns_transaction
    verify_dns_update_propagated
}

function main {
    parse_args $@
    validate_args
    perform_dns_updates
}

main $@
