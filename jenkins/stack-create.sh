#!/bin/bash

set -e

source ~/.openrc

KEY_NAME="jenkins"
FLAVOR=${FLAVOR:-"performance1-8"}
RPC_GIT_REPO="https://github.com/stackforge/os-ansible-deployment"
RPC_GIT_VERSION=${RPC_GIT_VERSION:-"master"}
HEAT_GIT_REPO="https://github.com/mattt416/rpc_heat"
HEAT_GIT_VERSION=${HEAT_GIT_VERSION:-"master"}
CLUSTER_PREFIX=${CLUSTER_PREFIX:-$(date "+%Y%m%d%H%M")}
DEPLOY_LOGGING=${DEPLOY_LOGGING:-"True"}
DEPLOY_TEMPEST=${DEPLOY_TEMPEST:-"False"}
DEPLOY_SWIFT=${DEPLOY_SWIFT:-"True"}
DEPLOY_MONITORING=${DEPLOY_MONITORING:-"False"}
RACKSPACE_CLOUD_USERNAME="$OS_USERNAME"
RACKSPACE_CLOUD_API_KEY="$OS_API_KEY"
RACKSPACE_CLOUD_AUTH_URL="$OS_AUTH_URL"
RACKSPACE_CLOUD_PASSWORD="$OS_PASSWORD"
RACKSPACE_CLOUD_TENANT_ID="$OS_TENANT_ID"
GLANCE_DEFAULT_STORE="swift"
GLANCE_SWIFT_STORE_REGION="LON"
RUN_ANSIBLE=${RUN_ANSIBLE:-"False"}

heat stack-create -f rpc_multi_node.yml rpc-${CLUSTER_PREFIX} -P "key_name=${KEY_NAME};rpc_git_version=${RPC_GIT_VERSION};cluster_prefix=${CLUSTER_PREFIX};deploy_logging=${DEPLOY_LOGGING};deploy_tempest=${DEPLOY_TEMPEST};deploy_swift=${DEPLOY_SWIFT};deploy_monitoring=${DEPLOY_MONITORING};rackspace_cloud_username=${RACKSPACE_CLOUD_USERNAME};rackspace_cloud_api_key=${RACKSPACE_CLOUD_API_KEY};rackspace_cloud_auth_url=${RACKSPACE_CLOUD_AUTH_URL};rackspace_cloud_password=${RACKSPACE_CLOUD_PASSWORD};rackspace_cloud_tenant_id=${RACKSPACE_CLOUD_TENANT_ID};glance_default_store=${GLANCE_DEFAULT_STORE};glance_swift_store_region=${GLANCE_SWIFT_STORE_REGION};flavor=${FLAVOR};rpc_git_repo=${RPC_GIT_REPO};heat_git_repo=${HEAT_GIT_REPO};heat_git_version=${HEAT_GIT_VERSION};run_ansible=${RUN_ANSIBLE}"

exit_status=-1

while [ $exit_status -lt 0 ] ; do
  sleep 30
  stack_status=$(heat stack-list 2>&1 | grep rpc-${CLUSTER_PREFIX} | awk -F\| '{print $4}' | sed -e 's/\s//g')
  if [ "$stack_status" = "CREATE_COMPLETE" ]; then
    exit_status=0
  elif [ "$stack_status" = "CREATE_FAILED" ]; then
    exit_status=1
  fi
done

exit $exit_status
