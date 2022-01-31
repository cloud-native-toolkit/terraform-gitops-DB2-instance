SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

CHART_DIR=$(cd "${MODULE_DIR}/chart/ibm-db2"; pwd -P)

NAME="$1"
DEST_DIR="$2"

echo "Name"
echo "${NAME}"

echo "DEST Dir"
echo "${DEST_DIR}"

echo "Chart Dir"
echo "${CHART_DIR}"

## Add logic here to put the yaml resource content in DEST_DIR

find "${DEST_DIR}" -name "*"

#SERVER_VALUES_FILE="$2"

mkdir -p "${DEST_DIR}"

cp -R "${CHART_DIR}"/* "${DEST_DIR}"