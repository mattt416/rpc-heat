#!/bin/bash

set -e

CLOUD_CREDS=${CLOUD_CREDS:-"~/.openrc"}
source $CLOUD_CREDS

CONTROLLER1_IP=$(heat output-show ${CLUSTER_PREFIX} controller1_ip | sed -e 's/"//g')
CHECKOUT="/opt/rpc-extras/"
SSH_KEY=${SSH_KEY:-"~/.ssh/jenkins"}
SSH_OPTS="-o StrictHostKeyChecking=no -o GSSAPIAuthentication=no -o HashKnownHosts=no -o UserKnownHostsFile=/dev/null"
DEPLOY_MONITORING=${DEPLOY_MONITORING:-"no"}


if [ $DEPLOY_MONITORING = "yes" ]; then
  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/playbooks && openstack-ansible setup-maas.yml"
  echo "Testing MaaS checks ..."
  scp -i $SSH_KEY $SSH_OPTS jenkins/rpc-maas-tool.py root@${CONTROLLER1_IP}:${CHECKOUT}/scripts
#  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/playbooks && ansible hosts -m shell -a 'free -m'"
#  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/playbooks && ansible hosts -m shell -a 'tail -20 /var/log/rackspace-monitoring-agent.log'"
#  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/playbooks && ansible hosts -m shell -a 'stop rackspace-monitoring-agent && sleep 10 && start rackspace-monitoring-agent'"
#  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/playbooks && ansible hosts -m shell -a 'free -m'"
#  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/playbooks && ansible hosts -m shell -a 'tail -20 /var/log/rackspace-monitoring-agent.log'"
  ssh -l root -i $SSH_KEY $SSH_OPTS $CONTROLLER1_IP "cd ${CHECKOUT}/scripts && python rpc-maas-tool.py check --prefix ${CLUSTER_PREFIX}"
  echo "Done."
fi
