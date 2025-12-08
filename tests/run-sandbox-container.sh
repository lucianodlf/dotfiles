HOST_DIR="."
CONTAINER_USERNAME="rafiki"
CONTAINER_DIR="/home/$CONTAINER_USERNAME/dotfiles" # Asegúrate de que este directorio existe en la imagen
CONTAINER_TAGNAME="dotfiles-test:latest"

docker run -it --rm \
  -u rafiki:rafiki \
  -v $HOST_DIR:$CONTAINER_DIR \
  $CONTAINER_TAGNAME bash -c "$CONTAINER_DIR/scripts/install.sh && exec /bin/bash"
