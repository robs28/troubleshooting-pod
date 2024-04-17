#!/bin/sh

# Check pod status
while true; do
    pod_status=$(kubectl get pods -n your-namespace -o json | jq '.items[] | select(.status.conditions[] | .status=="False" and .reason=="Unschedulable")')
    if [ ! -z "$pod_status" ]; then
        echo "Volume attachment issue detected. Proceeding with troubleshooting steps."

        # Extract pod and PVC names
        pod_name=$(echo $pod_status | jq -r '.metadata.name')
        pvc_name=$(echo $pod_status | jq -r '.spec.volumes[] | select(.persistentVolumeClaim) | .persistentVolumeClaim.claimName')

        # Step 1: Force delete pod and PVC
        kubectl delete pod $pod_name -n your-namespace --force
        kubectl delete pvc $pvc_name -n your-namespace --force

        # Step 2: Recreate the pod only
        sleep 10  # Wait for a few seconds before recreating the pod
        kubectl delete pod $pod_name -n your-namespace --force

        # Step 3: Verification step (could loop or end script based on policy)
    fi
    sleep 20  # Check every 20 seconds
done
