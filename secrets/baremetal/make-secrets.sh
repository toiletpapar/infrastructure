SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
NAMES="production-psql production-session-key"
for NAME in $NAMES
do
  echo "Processing $NAME"

  BASE64=$(cat $SCRIPT_DIR/credentials/$NAME | base64 -w 0)
  echo -e "\
apiVersion: v1
kind: Secret
metadata:
  name: $NAME
type: Opaque
data:
  $NAME: $BASE64" > \
  $SCRIPT_DIR/k8s/$NAME.yaml
  
  kubectl apply -f $SCRIPT_DIR/k8s/$NAME.yaml
done