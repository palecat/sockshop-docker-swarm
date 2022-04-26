#!/bin/bash

for node_type in manager worker
do
  
TOKEN=$(ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SSH_USER@$HOST sudo docker swarm join-token $node_type -q)
  
cat >scripts/$node_type.join.sh <<EOF
#!/bin/bash
sudo docker swarm join --token ${TOKEN} ${HOST}:2377
EOF

done
